了解しました。ここでは **「API 専用のレイヤを分けたマイクロ構成」** ではなく、
1 つの Express 5 アプリ内で **EJS による画面描画と JSON API を同時に扱う “モノリシック構成”** へ落とし込む手順・雛形を示します。
（＝「まず低コストで全部入り PoC を動かし、あとで必要に応じてレイヤ分割する」イメージです）

---

## 1. 技術スタック差分 ✨

| 区分      | 既存ガイド                | **モノリシック EJS 版**                            |
| ------- | -------------------- | ------------------------------------------- |
| ビューエンジン | なし（API 専用）           | **EJS** ＋ express-ejs-layouts（共通レイアウト）      |
| 静的配信    | `express.static`     | 同左。`/public` 配下に CSS/JS/画像                  |
| 認証 UI   | Postman/Swagger      | EJS で簡易ログイン画面（フォーム POST）                    |
| OpenAPI | openapi-backend      | 任意。PoC では **/api/** プレフィックスのみに適用可           |
| MVC 階層  | REST Controller オンリー | `views/`, `viewControllers/` を追加（画面用コントローラ） |

> **ポイント**
>
> * **API と画面の Router を分離**し、URL 空間で衝突させない（例：`/api/users` と `/users`）。
> * テスト資産（Jest/Supertest）は API 用にそのまま流用可能。
> * 将来マイクロサービスへ切り出す際、画面用コントローラを Next.js などに差し替えやすい設計にしておく。

---

## 2. 変更後ディレクトリ構成

```
project-root/
├── src/
│   ├── controllers/         # JSON API
│   ├── viewControllers/     # 画面レンダリング (EJS)
│   ├── routes/
│   │   ├── api/             # API ルーター
│   │   └── web/             # 画面ルーター
│   ├── views/               # EJS テンプレート
│   │   ├── layouts/         # 共通レイアウト
│   │   └── partials/        # パーシャル
│   └── server.js
├── public/                  # CSS, JS, images
└── ... （既存と同じ）
```

---

## 3. `server.js` 主要差分

```js
import express from 'express';
import 'express-async-errors';
import path from 'node:path';
import helmet from 'helmet';
import cors from 'cors';
import morgan from 'morgan';
import cookieParser from 'cookie-parser';
import session from 'express-session';
import layouts from 'express-ejs-layouts';
import { fileURLToPath } from 'node:url';
import apiRouter from './routes/api/index.js';
import webRouter from './routes/web/index.js';
import { notFound, errorHandler } from './middlewares/errorHandler.js';

const app = express();
const __dirname = path.dirname(fileURLToPath(import.meta.url));

// === View engine ===
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(layouts);

// === Global middleware ===
app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));   // form POST 用
app.use(cookieParser());
app.use(
  session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: { secure: app.get('env') === 'production' },
  }),
);
app.use(express.static(path.join(__dirname, '..', 'public')));

// === Routes ===
app.use('/api', apiRouter);   // JSON API
app.use('/', webRouter);      // 画面

// === 404 & Error ===
app.use(notFound);
app.use(errorHandler);

export default app;
```

---

## 4. 画面ルーター & コントローラ雛形

### `routes/web/index.js`

```js
import { Router } from 'express';
import * as userCtrl from '../../viewControllers/user.controller.js';
import { requireAuth } from '../../middlewares/auth.js';

const router = Router();

router.get('/', userCtrl.index);          // TOP
router.get('/login', userCtrl.showLogin);
router.post('/login', userCtrl.login);
router.get('/logout', userCtrl.logout);
router.get('/dashboard', requireAuth, userCtrl.dashboard);

export default router;
```

### `viewControllers/user.controller.js`

```js
export const index = (req, res) => {
  res.render('pages/index', { title: 'Home' });
};

export const showLogin = (req, res) => {
  res.render('pages/login', { title: 'Login' });
};

export const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    // lowdb + bcrypt でユーザー照合
    // ...
    req.session.user = { id: user.id, email: user.email };
    return res.redirect('/dashboard');
  } catch (err) {
    return next(err);
  }
};

export const logout = (req, res) => {
  req.session.destroy(() => res.redirect('/'));
};

export const dashboard = (req, res) => {
  res.render('pages/dashboard', { user: req.session.user });
};
```

---

## 5. EJS テンプレート例

`views/layouts/main.ejs`

```ejs
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8" />
  <title><%= title %> | Express5-EJS-PoC</title>
  <link rel="stylesheet" href="/css/main.css" />
</head>
<body>
  <%- body %>
</body>
</html>
```

`views/pages/index.ejs`

```ejs
<% layout('layouts/main') -%>
<h1 class="text-2xl font-bold">Welcome!</h1>
<p><a href="/login">ログイン</a></p>
```

---

## 6. 依存関係追加／削除

```bash
npm i ejs express-ejs-layouts             # 追加
npm rm swagger-ui-express                 # 画面中心なら不要
```

> OpenAPI 連携を維持したい場合はそのまま残し、
> **`/api-docs`** の Swagger UI は開発時限定で公開すると安全です。

---

## 7. セキュリティ面の注意

| 対策      | 実装ポイント                                                                                      |
| ------- | ------------------------------------------------------------------------------------------- |
| CSRF    | `csurf` を POST ルートに注入し、EJS 側で `<input type="hidden" name="_csrf" value="<%= csrfToken %>">` |
| XSS     | `helmet` に加えて EJS の自動エスケープを信頼。動的 HTML 挿入時は `<%- %>` ではなく `<%= %>` を使う                       |
| セッション固定 | ログイン成功後 `req.session.regenerate()`                                                          |
| HTTPS   | 本番は `trust proxy` + `cookie: { secure: true, sameSite: 'lax' }`                             |

---

## 8. Make タスク差分（抜粋）

```Makefile
# 画面ホットリロード
dev-web:
  nodemon --ext js,ejs,json,yaml --exec "node src/server.js"

# CSS/JS ビルド（任意: vite, esbuild など）
assets:
  vite build
```

---

## 9. 漸進的ステップ

1. **最小構成**: ルート `/` + `/login` を EJS で描画し、API 依存ゼロで起動確認。
2. **セッション認証**: lowdb にユーザレコードを作り、bcrypt 照合・セッション保存。
3. **API 併設**: `/api/users` の JSON CRUD を追加し、EJS 側から `fetch` 呼び出しで連携。
4. **OpenAPI 導入（任意）**: `/api` 配下のみ `openapi-backend` でバリデーション。
5. **CI/CD & Docker**: 既存ガイドの GitHub Actions・Dockerfile はそのまま流用可。

---

これで **「全部入りだが 1 サーバーで完結」** という PoC が素早く立ち上げられ、
将来 Next.js や独立 API へのリファクタも見据えた柔軟性を確保できます。
他に調整したい点があれば遠慮なく教えてください！
