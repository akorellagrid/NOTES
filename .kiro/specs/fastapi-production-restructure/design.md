# Design Document: FastAPI Production Restructure

## Overview

This document describes the technical architecture for restructuring both a FastAPI Notes API and its frontend from flat structures to production-grade modular architectures. The backend restructure organizes code into logical layers (API, service, CRUD, schema), implements database migrations with Alembic, secures environment configuration, adds comprehensive end-to-end testing, and enhances Pydantic validation for robust input handling. The frontend restructure modernizes from basic HTML/JS/CSS to a well-organized vanilla JavaScript modular architecture with clean separation of concerns, organized CSS architecture, build optimization, and comprehensive testing while maintaining the existing UI design and Grid Dynamics branding.

The new structure follows a layered architecture pattern with clear separation of concerns:

**Backend Architecture:**
- **API Layer**: HTTP endpoints that handle requests and responses
- **Service Layer**: Business logic that orchestrates operations
- **CRUD Layer**: Data access that encapsulates database operations
- **Schema Layer**: Pydantic models for request/response validation
- **Core Layer**: Application configuration and settings
- **Database Layer**: Connection management and session handling
- **Middleware Layer**: Request/response processing and exception handling
- **Utils Layer**: Shared utility functions

**Frontend Architecture:**
- **Module Layer**: Vanilla JavaScript ES6 modules (api.js, ui.js, utils.js, main.js)
- **CSS Architecture**: Organized stylesheets (components.css, layout.css, themes.css)
- **Build Layer**: Simple build system for concatenation, minification, and optimization
- **Asset Layer**: Static resources (images, fonts, icons) management
- **Configuration Layer**: Environment-specific settings and feature flags
- **Testing Layer**: Basic unit tests and integration tests for JavaScript modules
- **Development Layer**: Live reload server and development tooling

## Architecture

### Layered Architecture

**Backend Architecture:**
```
┌─────────────────────────────────────────────────────────────┐
│                     FastAPI Application                      │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   API Layer  │  │  Service     │  │   CRUD Layer │       │
│  │  (Routes)    │→ │  Layer       │→ │  (Database)  │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│         ↓                  ↓                  ↓              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  Schema      │  │  Core        │  │  Database    │       │
│  │  (Models)    │  │  (Config)    │  │  (Session)   │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
         ↓                  ↓                  ↓
┌─────────────────────────────────────────────────────────────┐
│                     Supporting Layers                        │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │ Middleware   │  │  Utils       │  │  Alembic     │       │
│  │ (Processing) │  │  (Helpers)   │  │  (Migrations)│       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

**Frontend Architecture:**
```
┌─────────────────────────────────────────────────────────────┐
│                   Vanilla JavaScript App                     │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  Module      │  │  CSS         │  │  Asset       │       │
│  │  Layer       │→ │  Architecture│→ │  Layer       │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│         ↓                  ↓                  ↓              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  API         │  │  UI          │  │  Utils       │       │
│  │  Module      │  │  Module      │  │  Module      │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
         ↓                  ↓                  ↓
┌─────────────────────────────────────────────────────────────┐
│                     Build & Development                      │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  Build       │  │  Testing     │  │  Development │       │
│  │  System      │  │  Layer       │  │  Tooling     │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### Directory Structure

**Backend Structure:**
```
backend/
├── app/
│   ├── admin/              # Admin panel endpoints
│   │   ├── api/           # Admin API routes
│   │   ├── crud/          # Admin CRUD operations
│   │   ├── model/         # Admin database models
│   │   ├── schema/        # Admin Pydantic schemas
│   │   ├── service/       # Admin business logic
│   │   └── tests/         # Admin tests
│   ├── task/              # Task management endpoints
│   │   ├── api/           # Task API routes
│   │   ├── crud/          # Task CRUD operations
│   │   ├── model/         # Task database models
│   │   ├── schema/        # Task Pydantic schemas
│   │   ├── service/       # Task business logic
│   │   └── tests/         # Task tests
│   └── notes/             # Notes endpoints (existing)
│       ├── api/           # Notes API routes
│       ├── crud/          # Notes CRUD operations
│       ├── model/         # Notes database models
│       ├── schema/        # Notes Pydantic schemas
│       ├── service/       # Notes business logic
│       └── tests/         # Notes tests
├── common/                # Common utilities shared across modules
├── core/                  # Core application configuration
│   ├── __init__.py
│   ├── config.py          # Configuration settings
│   └── logging.py         # Logging configuration
├── database/              # Database connection and session management
│   ├── __init__.py
│   ├── engine.py          # Database engine creation
│   ├── session.py         # Session factory configuration
│   └── dependencies.py    # Dependency injection functions
├── middleware/            # FastAPI middleware components
│   ├── __init__.py
│   ├── request_logger.py  # Request/response logging
│   └── exception_handler.py  # Exception handling
├── utils/                 # Shared utility functions
│   ├── __init__.py
│   ├── validators.py      # Custom validators
│   └── helpers.py         # Helper functions
├── alembic/               # Database migrations
│   ├── env.py
│   ├── script.py.mako
│   └── versions/
├── scripts/               # Utility scripts
│   ├── migrate.py         # Migration runner
│   └── seed.py            # Database seeding
├── sql/                   # SQL scripts
│   └── init.sql           # Initial schema
├── static/                # Static files
│   └── favicon.ico
├── templates/             # HTML templates
│   └── index.html
└── tests/                 # End-to-end and integration tests
    ├── conftest.py        # Test fixtures
    ├── test_api/          # API endpoint tests
    │   ├── test_notes.py
    │   └── test_admin.py
    └── test_service/      # Service layer tests
        └── test_notes.py
```

**Frontend Structure:**
```
frontend/
├── public/                # Built application output
│   ├── index.html         # Main HTML file
│   ├── app.bundle.js      # Bundled JavaScript
│   ├── styles.bundle.css  # Bundled CSS
│   ├── assets/            # Optimized static assets
│   │   ├── images/        # Compressed images
│   │   ├── fonts/         # Web fonts
│   │   └── icons/         # Icon files
│   └── favicon.ico        # Favicon
├── src/                   # Source code
│   ├── js/                # JavaScript modules
│   │   ├── api.js         # API communication module
│   │   ├── ui.js          # DOM manipulation and UI logic
│   │   ├── utils.js       # Utility functions and helpers
│   │   ├── config.js      # Environment configuration
│   │   └── main.js        # Application entry point
│   ├── css/               # Stylesheets
│   │   ├── components.css # Component-specific styles
│   │   ├── layout.css     # Layout and grid systems
│   │   ├── themes.css     # Color schemes and theme variables
│   │   └── main.css       # Main stylesheet (imports others)
│   ├── assets/            # Source assets
│   │   ├── images/        # Original images
│   │   ├── fonts/         # Font files
│   │   └── icons/         # Icon source files
│   └── templates/         # HTML templates
│       └── index.html     # Source HTML template
├── tests/                 # Test files
│   ├── js/                # JavaScript tests
│   │   ├── api.test.js    # API module tests
│   │   ├── ui.test.js     # UI module tests
│   │   └── utils.test.js  # Utils module tests
│   ├── fixtures/          # Test data and fixtures
│   └── setup.js           # Test setup configuration
├── build/                 # Build configuration and scripts
│   ├── webpack.config.js  # Webpack configuration
│   ├── build.js           # Build script
│   └── dev-server.js      # Development server
├── .env.example           # Environment variables template
├── .env.local             # Local environment variables
├── .gitignore             # Git ignore rules
├── .eslintrc.js           # ESLint configuration
├── .prettierrc            # Prettier configuration
├── package.json           # Dependencies and scripts
└── README.md              # Documentation
```

### Component Interactions

1. **Request Flow**:
   - HTTP request arrives at FastAPI router
   - Request validation via Pydantic schema
   - Request logging middleware processes request
   - API route handler delegates to service layer
   - Service layer orchestrates CRUD operations
   - CRUD layer executes database queries
   - Response is serialized via Pydantic schema
   - Response logging middleware processes response
   - Response returned to client

2. **Error Flow**:
   - Exception occurs in any layer
   - Exception handler middleware catches exception
   - Full stack trace logged
   - Generic error response returned to client

3. **Startup Flow**:
   - Application starts
   - Core configuration loaded from environment
   - Database engine created with connection pooling
   - Database connection verified with retry logic
   - Alembic migrations applied if needed
   - Application ready to accept requests

## Components and Interfaces

### Backend Components

#### API Layer

The API layer contains HTTP endpoint definitions using FastAPI routers. Each module handles a specific domain (notes, admin, task).

**Interface**:
- `notes/api/routes.py`: Notes endpoint handlers
- `admin/api/routes.py`: Admin endpoint handlers
- `task/api/routes.py`: Task endpoint handlers

**Key Functions**:
- `create_note(payload: NoteCreate) -> Note`: Create a new note
- `get_note(note_id: int) -> Note`: Retrieve a note by ID
- `update_note(note_id: int, payload: NoteUpdate) -> Note`: Update a note
- `delete_note(note_id: int) -> None`: Delete a note
- `list_notes() -> list[Note]`: List all notes

#### Service Layer

The service layer contains business logic that orchestrates CRUD operations. Each module handles domain-specific rules and validation.

**Interface**:
- `notes/service/notes_service.py`: Notes business logic
- `admin/service/admin_service.py`: Admin business logic
- `task/service/task_service.py`: Task business logic

**Key Functions**:
- `create_note(db: Session, title: str, content: str) -> NoteModel`: Create note with validation
- `get_note(db: Session, note_id: int) -> NoteModel | None`: Retrieve note
- `update_note(db: Session, note_id: int, title: str | None, content: str | None) -> NoteModel`: Update note
- `delete_note(db: Session, note_id: int) -> None`: Delete note
- `list_notes(db: Session) -> list[NoteModel]`: List all notes

#### CRUD Layer

The CRUD layer contains database operations using SQLAlchemy. Each module handles data access for a specific domain.

**Interface**:
- `notes/crud/notes_crud.py`: Notes data access
- `admin/crud/admin_crud.py`: Admin data access
- `task/crud/task_crud.py`: Task data access

**Key Functions**:
- `create_note(db: Session, note: NoteModel) -> NoteModel`: Create note
- `get_note(db: Session, note_id: int) -> NoteModel | None`: Retrieve note
- `update_note(db: Session, note_id: int, title: str | None, content: str | None) -> NoteModel | None`: Update note
- `delete_note(db: Session, note_id: int) -> None`: Delete note
- `get_notes(db: Session, skip: int = 0, limit: int = 100) -> list[NoteModel]`: List notes

#### Schema Layer

The schema layer contains Pydantic models for request/response validation. Each module defines schemas for its domain.

**Interface**:
- `notes/schema/schemas.py`: Notes request/response models
- `admin/schema/schemas.py`: Admin request/response models
- `task/schema/schemas.py`: Task request/response models

**Key Models**:
- `NoteCreate`: Request model for creating notes
- `NoteUpdate`: Request model for updating notes
- `Note`: Response model for notes

#### Core Layer

The core layer contains application configuration and settings.

**Interface**:
- `core/config.py`: Configuration settings
- `core/logging.py`: Logging configuration

**Key Classes**:
- `Settings`: Pydantic settings model with environment variable loading
- `get_settings()`: Function to get settings instance

#### Database Layer

The database layer contains connection management and session handling.

**Interface**:
- `database/engine.py`: Database engine creation
- `database/session.py`: Session factory configuration
- `database/dependencies.py`: Dependency injection functions

**Key Functions**:
- `get_engine() -> Engine`: Create database engine
- `get_session() -> Session`: Get database session
- `get_db() -> Generator[Session, None, None]`: Dependency for FastAPI routes

#### Middleware Layer

The middleware layer contains request/response processing components.

**Interface**:
- `middleware/request_logger.py`: Request/response logging
- `middleware/exception_handler.py`: Exception handling

**Key Components**:
- `RequestLoggingMiddleware`: Logs all requests and responses
- `ExceptionHandlerMiddleware`: Handles unhandled exceptions

#### Utils Layer

The utils layer contains shared utility functions.

**Interface**:
- `utils/validators.py`: Custom validators
- `utils/helpers.py`: Helper functions

**Key Functions**:
- `validate_not_empty(value: str) -> str`: Validate string is not empty
- `strip_whitespace(value: str) -> str`: Strip leading/trailing whitespace

### Frontend Components

#### Module Layer

The module layer contains vanilla JavaScript ES6 modules organized by functionality and responsibility.

**Core Modules**:
- `js/api.js`: HTTP client and API communication
- `js/ui.js`: DOM manipulation and user interface logic
- `js/utils.js`: Utility functions and helpers
- `js/config.js`: Environment configuration and settings
- `js/main.js`: Application entry point and module coordination

**Module Interface Example**:
```javascript
// js/api.js
export class ApiClient {
  constructor(baseURL = '/api') {
    this.baseURL = baseURL;
  }

  async request(method, path, data = null) {
    const url = `${this.baseURL}${path}`;
    const options = {
      method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    if (data) {
      options.body = JSON.stringify(data);
    }

    const response = await fetch(url, options);
    
    if (!response.ok) {
      const error = await response.text();
      throw new Error(error || `Request failed (${response.status})`);
    }

    if (response.status === 204) return null;
    return await response.json();
  }

  // Notes API methods
  async createNote(data) {
    return this.request('POST', '/notes', data);
  }

  async getNote(id) {
    return this.request('GET', `/notes/${id}`);
  }

  async updateNote(id, data) {
    return this.request('PATCH', `/notes/${id}`, data);
  }

  async deleteNote(id) {
    return this.request('DELETE', `/notes/${id}`);
  }

  async listNotes() {
    return this.request('GET', '/notes');
  }
}

export const apiClient = new ApiClient();
```

#### CSS Architecture

The CSS architecture provides organized styling with clear separation of concerns and maintainable structure.

**CSS Organization**:
- `css/components.css`: Component-specific styles (buttons, forms, cards)
- `css/layout.css`: Layout systems (grid, flexbox, containers)
- `css/themes.css`: Color schemes and theme variables
- `css/main.css`: Main stylesheet that imports all others

**CSS Architecture Example**:
```css
/* css/themes.css */
:root {
  /* Light theme (default) */
  --color-bg: #f6f7fb;
  --color-surface: rgba(0, 0, 0, 0.04);
  --color-text: rgba(0, 0, 0, 0.88);
  --color-text-muted: rgba(0, 0, 0, 0.62);
  --color-border: rgba(0, 0, 0, 0.1);
  --color-primary: #1d4ed8;
  --color-danger: #dc2626;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: #070a12;
    --color-surface: rgba(255, 255, 255, 0.06);
    --color-text: rgba(255, 255, 255, 0.92);
    --color-text-muted: rgba(255, 255, 255, 0.68);
    --color-border: rgba(255, 255, 255, 0.12);
    --color-primary: #60a5fa;
    --color-danger: #ff6b6b;
  }
}

/* css/components.css */
.button {
  border: 1px solid var(--color-border);
  background: linear-gradient(180deg, rgba(96, 165, 250, 0.22), rgba(96, 165, 250, 0.10));
  color: var(--color-text);
  padding: 10px 14px;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  transition: border-color 0.2s ease;
}

.button:hover {
  border-color: rgba(96, 165, 250, 0.55);
}

.button.secondary {
  background: transparent;
}

.button.danger {
  color: var(--color-danger);
}
```

#### UI Module

The UI module handles DOM manipulation, event handling, and user interface logic.

**UI Module Interface**:
```javascript
// js/ui.js
export class UIManager {
  constructor() {
    this.elements = this.initializeElements();
    this.state = {
      expandedNoteId: null,
      loading: false,
    };
  }

  initializeElements() {
    return {
      statusEl: document.getElementById('status'),
      listEl: document.getElementById('notesList'),
      formEl: document.getElementById('createForm'),
      titleEl: document.getElementById('title'),
      contentEl: document.getElementById('content'),
      refreshBtn: document.getElementById('refreshBtn'),
    };
  }

  setStatus(message, isError = false) {
    this.elements.statusEl.textContent = message;
    this.elements.statusEl.classList.toggle('danger', isError);
  }

  resetForm() {
    this.elements.titleEl.value = '';
    this.elements.contentEl.value = '';
  }

  renderNotes(notes) {
    this.elements.listEl.innerHTML = '';
    
    if (!notes.length) {
      this.renderEmptyState();
      return;
    }

    notes.forEach(note => {
      const noteElement = this.createNoteElement(note);
      this.elements.listEl.appendChild(noteElement);
    });
  }

  createNoteElement(note) {
    const li = document.createElement('li');
    li.className = 'noteItem';
    
    const details = document.createElement('details');
    details.className = 'note';
    details.open = this.state.expandedNoteId === note.id;
    
    // Create note summary and body
    const summary = this.createNoteSummary(note);
    const body = this.createNoteBody(note);
    
    details.appendChild(summary);
    details.appendChild(body);
    
    // Handle expand/collapse
    details.addEventListener('toggle', () => {
      this.handleNoteToggle(details, note);
    });
    
    li.appendChild(details);
    return li;
  }

  // Additional UI methods...
}

export const uiManager = new UIManager();
```

#### Utils Module

The utils module contains shared utility functions and helpers used across the application.

**Utils Module Interface**:
```javascript
// js/utils.js
export const formatters = {
  date(isoString) {
    try {
      return new Date(isoString).toLocaleString();
    } catch {
      return isoString;
    }
  },

  truncate(text, maxLength = 100) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
  },
};

export const validators = {
  required(value) {
    return value && value.trim().length > 0;
  },

  maxLength(value, max) {
    return value.length <= max;
  },

  minLength(value, min) {
    return value.length >= min;
  },

  validateNote(data) {
    const errors = {};
    
    if (!this.required(data.title)) {
      errors.title = 'Title is required';
    } else if (!this.maxLength(data.title, 200)) {
      errors.title = 'Title must be 200 characters or less';
    }
    
    if (!this.required(data.content)) {
      errors.content = 'Content is required';
    } else if (!this.maxLength(data.content, 10000)) {
      errors.content = 'Content must be 10,000 characters or less';
    }
    
    return {
      isValid: Object.keys(errors).length === 0,
      errors,
    };
  },
};

export const debounce = (func, wait) => {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
};

export const storage = {
  get(key, defaultValue = null) {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : defaultValue;
    } catch {
      return defaultValue;
    }
  },

  set(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
      return true;
    } catch {
      return false;
    }
  },

  remove(key) {
    try {
      localStorage.removeItem(key);
      return true;
    } catch {
      return false;
    }
  },
};
```

#### Build System

The build system handles bundling, optimization, and development tooling for the frontend.

**Build Configuration Example**:
```javascript
// build/webpack.config.js
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');

const isProduction = process.env.NODE_ENV === 'production';

module.exports = {
  mode: isProduction ? 'production' : 'development',
  entry: './src/js/main.js',
  output: {
    path: path.resolve(__dirname, '../public'),
    filename: isProduction ? 'app.[contenthash].js' : 'app.bundle.js',
    clean: true,
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env'],
          },
        },
      },
      {
        test: /\.css$/,
        use: [
          isProduction ? MiniCssExtractPlugin.loader : 'style-loader',
          'css-loader',
        ],
      },
      {
        test: /\.(png|svg|jpg|jpeg|gif)$/i,
        type: 'asset/resource',
        generator: {
          filename: 'assets/images/[name].[hash][ext]',
        },
      },
      {
        test: /\.(woff|woff2|eot|ttf|otf)$/i,
        type: 'asset/resource',
        generator: {
          filename: 'assets/fonts/[name].[hash][ext]',
        },
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './src/templates/index.html',
      filename: 'index.html',
    }),
    ...(isProduction
      ? [
          new MiniCssExtractPlugin({
            filename: 'styles.[contenthash].css',
          }),
        ]
      : []),
  ],
  optimization: {
    minimize: isProduction,
    minimizer: [
      new TerserPlugin({
        terserOptions: {
          compress: {
            drop_console: true,
          },
        },
      }),
      new CssMinimizerPlugin(),
    ],
  },
  devServer: {
    static: {
      directory: path.join(__dirname, '../public'),
    },
    port: 3000,
    hot: true,
    proxy: {
      '/api': 'http://localhost:8000',
    },
  },
  devtool: isProduction ? 'source-map' : 'eval-source-map',
};
```

## Data Models

### Backend Data Models

#### Pydantic Models (Schema Layer)

```python
# notes/schema/schemas.py
from __future__ import annotations

from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field, field_validator


class NoteCreate(BaseModel):
    """Request model for creating a note."""
    title: str = Field(
        min_length=1,
        max_length=200,
        description="Note title (1-200 characters)"
    )
    content: str = Field(
        min_length=1,
        max_length=10_000,
        description="Note content (1-10,000 characters)"
    )

    @field_validator("title", "content", mode="before")
    @classmethod
    def strip_whitespace(cls, value: str) -> str:
        """Strip leading and trailing whitespace from string fields."""
        if isinstance(value, str):
            return value.strip()
        return value

    @field_validator("title", "content")
    @classmethod
    def validate_not_empty(cls, value: str) -> str:
        """Validate that string is not empty after stripping."""
        if not value:
            raise ValueError("Field cannot be empty")
        return value


class NoteUpdate(BaseModel):
    """Request model for updating a note."""
    title: str | None = Field(
        default=None,
        min_length=1,
        max_length=200,
        description="Updated note title"
    )
    content: str | None = Field(
        default=None,
        min_length=1,
        max_length=10_000,
        description="Updated note content"
    )

    @field_validator("title", "content", mode="before")
    @classmethod
    def strip_whitespace(cls, value: str) -> str | None:
        """Strip leading and trailing whitespace from string fields."""
        if isinstance(value, str):
            return value.strip()
        return value

    @field_validator("title", "content")
    @classmethod
    def validate_not_empty(cls, value: str) -> str:
        """Validate that string is not empty after stripping."""
        if not value:
            raise ValueError("Field cannot be empty")
        return value


class Note(BaseModel):
    """Response model for a note."""
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    content: str
    created_at: datetime
    updated_at: datetime
```

#### SQLAlchemy Models (Database Layer)

```python
# notes/model/models.py
from __future__ import annotations

from datetime import datetime
from sqlalchemy import DateTime, Integer, String, Text, func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    """Base class for all SQLAlchemy models."""
    pass


class NoteModel(Base):
    """Database model for notes."""
    __tablename__ = "notes"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )
```

#### Database Schema

```sql
-- sql/init.sql
CREATE TABLE notes (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_notes_id ON notes(id);
```

### Frontend Data Models

#### JavaScript Object Structures

Since we're using vanilla JavaScript, data models are represented as plain JavaScript objects with JSDoc comments for documentation.

```javascript
// js/models.js

/**
 * @typedef {Object} Note
 * @property {number} id - Unique identifier
 * @property {string} title - Note title
 * @property {string} content - Note content
 * @property {string} created_at - ISO date string
 * @property {string} updated_at - ISO date string
 */

/**
 * @typedef {Object} CreateNoteRequest
 * @property {string} title - Note title (1-200 characters)
 * @property {string} content - Note content (1-10,000 characters)
 */

/**
 * @typedef {Object} UpdateNoteRequest
 * @property {string} [title] - Updated note title
 * @property {string} [content] - Updated note content
 */

/**
 * @typedef {Object} ApiResponse
 * @property {*} data - Response data
 * @property {string} [message] - Optional message
 */

/**
 * @typedef {Object} ApiError
 * @property {string|ValidationError[]} detail - Error details
 */

/**
 * @typedef {Object} ValidationError
 * @property {(string|number)[]} loc - Error location path
 * @property {string} msg - Error message
 * @property {string} type - Error type
 */

/**
 * @typedef {Object} AppConfig
 * @property {string} apiBaseUrl - Base URL for API requests
 * @property {string} environment - Current environment (development/production)
 * @property {boolean} enableDevTools - Whether dev tools are enabled
 * @property {string} version - Application version
 */

/**
 * @typedef {Object} UIState
 * @property {number|null} expandedNoteId - Currently expanded note ID
 * @property {boolean} loading - Loading state
 * @property {string|null} error - Current error message
 * @property {Object} modals - Modal visibility states
 * @property {boolean} modals.createNote - Create note modal visibility
 * @property {boolean} modals.editNote - Edit note modal visibility
 * @property {boolean} modals.deleteNote - Delete note modal visibility
 */

/**
 * @typedef {Object} FormState
 * @property {Object} values - Form field values
 * @property {Object} errors - Form validation errors
 * @property {Object} touched - Touched field states
 * @property {boolean} isSubmitting - Form submission state
 * @property {boolean} isValid - Form validation state
 */
```

#### Configuration Objects

```javascript
// js/config.js

/**
 * Application configuration based on environment
 */
export const config = {
  development: {
    apiBaseUrl: '/api',
    environment: 'development',
    enableDevTools: true,
    version: '1.0.0',
    debug: true,
  },
  production: {
    apiBaseUrl: '/api',
    environment: 'production',
    enableDevTools: false,
    version: '1.0.0',
    debug: false,
  },
};

/**
 * Get current configuration based on environment
 * @returns {Object} Current configuration object
 */
export function getConfig() {
  const env = process.env.NODE_ENV || 'development';
  return config[env] || config.development;
}

/**
 * API endpoints configuration
 */
export const endpoints = {
  notes: {
    list: '/notes',
    create: '/notes',
    get: (id) => `/notes/${id}`,
    update: (id) => `/notes/${id}`,
    delete: (id) => `/notes/${id}`,
  },
  health: '/health',
};
```

#### Validation Schemas

```javascript
// js/validation.js

/**
 * Validation rules for note fields
 */
export const noteValidationRules = {
  title: {
    required: true,
    minLength: 1,
    maxLength: 200,
    trim: true,
  },
  content: {
    required: true,
    minLength: 1,
    maxLength: 10000,
    trim: true,
  },
};

/**
 * Validate a note object against validation rules
 * @param {Object} note - Note object to validate
 * @param {string} note.title - Note title
 * @param {string} note.content - Note content
 * @returns {Object} Validation result with isValid and errors
 */
export function validateNote(note) {
  const errors = {};
  
  // Validate title
  if (!note.title || typeof note.title !== 'string') {
    errors.title = 'Title is required';
  } else {
    const title = note.title.trim();
    if (title.length === 0) {
      errors.title = 'Title cannot be empty';
    } else if (title.length > noteValidationRules.title.maxLength) {
      errors.title = `Title must be ${noteValidationRules.title.maxLength} characters or less`;
    }
  }
  
  // Validate content
  if (!note.content || typeof note.content !== 'string') {
    errors.content = 'Content is required';
  } else {
    const content = note.content.trim();
    if (content.length === 0) {
      errors.content = 'Content cannot be empty';
    } else if (content.length > noteValidationRules.content.maxLength) {
      errors.content = `Content must be ${noteValidationRules.content.maxLength} characters or less`;
    }
  }
  
  return {
    isValid: Object.keys(errors).length === 0,
    errors,
  };
}
```

#### State Management Objects

```javascript
// js/state.js

/**
 * Application state manager using simple object state
 */
export class AppState {
  constructor() {
    this.state = {
      notes: [],
      loading: false,
      error: null,
      ui: {
        expandedNoteId: null,
        modals: {
          createNote: false,
          editNote: false,
          deleteNote: false,
        },
      },
    };
    this.listeners = [];
  }

  /**
   * Get current state
   * @returns {Object} Current application state
   */
  getState() {
    return { ...this.state };
  }

  /**
   * Update state and notify listeners
   * @param {Object} updates - State updates to apply
   */
  setState(updates) {
    this.state = { ...this.state, ...updates };
    this.notifyListeners();
  }

  /**
   * Subscribe to state changes
   * @param {Function} listener - Callback function for state changes
   * @returns {Function} Unsubscribe function
   */
  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      const index = this.listeners.indexOf(listener);
      if (index > -1) {
        this.listeners.splice(index, 1);
      }
    };
  }

  /**
   * Notify all listeners of state changes
   */
  notifyListeners() {
    this.listeners.forEach(listener => listener(this.state));
  }

  // Note-specific state methods
  setNotes(notes) {
    this.setState({ notes });
  }

  addNote(note) {
    this.setState({ notes: [...this.state.notes, note] });
  }

  updateNote(updatedNote) {
    const notes = this.state.notes.map(note =>
      note.id === updatedNote.id ? updatedNote : note
    );
    this.setState({ notes });
  }

  deleteNote(noteId) {
    const notes = this.state.notes.filter(note => note.id !== noteId);
    this.setState({ notes });
  }

  setLoading(loading) {
    this.setState({ loading });
  }

  setError(error) {
    this.setState({ error });
  }

  setExpandedNote(noteId) {
    this.setState({
      ui: {
        ...this.state.ui,
        expandedNoteId: noteId,
      },
    });
  }
}

// Global state instance
export const appState = new AppState();
```pace';
      }
      return null;
    },
  },
};
```

#### HTTP Client Configuration

```javascript
// js/api-client.js

/**
 * HTTP client for API communication
 */
export class HttpClient {
  constructor(config = {}) {
    this.baseURL = config.baseURL || '/api';
    this.timeout = config.timeout || 10000;
    this.defaultHeaders = {
      'Content-Type': 'application/json',
      ...config.headers,
    };
    this.retries = config.retries || 3;
    this.retryDelay = config.retryDelay || 1000;
  }

  /**
   * Make HTTP request with retry logic
   * @param {Object} requestConfig - Request configuration
   * @returns {Promise<Object>} Response data
   */
  async request(requestConfig) {
    const { method, url, data, params, headers, timeout } = requestConfig;
    
    const fullUrl = new URL(url, this.baseURL);
    if (params) {
      Object.keys(params).forEach(key => {
        if (params[key] !== undefined && params[key] !== null) {
          fullUrl.searchParams.append(key, params[key]);
        }
      });
    }

    const options = {
      method,
      headers: { ...this.defaultHeaders, ...headers },
      signal: AbortSignal.timeout(timeout || this.timeout),
    };

    if (data && ['POST', 'PUT', 'PATCH'].includes(method)) {
      options.body = JSON.stringify(data);
    }

    let lastError;
    for (let attempt = 0; attempt <= this.retries; attempt++) {
      try {
        const response = await fetch(fullUrl.toString(), options);
        
        if (!response.ok) {
          const errorText = await response.text();
          throw new ApiError(errorText || `HTTP ${response.status}`, response.status);
        }

        if (response.status === 204) {
          return null;
        }

        return await response.json();
      } catch (error) {
        lastError = error;
        
        if (attempt < this.retries && this.shouldRetry(error)) {
          await this.delay(this.retryDelay * Math.pow(2, attempt));
          continue;
        }
        
        break;
      }
    }

    throw lastError;
  }

  /**
   * Determine if request should be retried
   * @param {Error} error - Request error
   * @returns {boolean} Whether to retry
   */
  shouldRetry(error) {
    if (error.name === 'AbortError') return false;
    if (error instanceof ApiError && error.status < 500) return false;
    return true;
  }

  /**
   * Delay execution for specified milliseconds
   * @param {number} ms - Milliseconds to delay
   * @returns {Promise<void>}
   */
  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // HTTP method helpers
  get(url, params, options = {}) {
    return this.request({ method: 'GET', url, params, ...options });
  }

  post(url, data, options = {}) {
    return this.request({ method: 'POST', url, data, ...options });
  }

  put(url, data, options = {}) {
    return this.request({ method: 'PUT', url, data, ...options });
  }

  patch(url, data, options = {}) {
    return this.request({ method: 'PATCH', url, data, ...options });
  }

  delete(url, options = {}) {
    return this.request({ method: 'DELETE', url, ...options });
  }
}

/**
 * Custom API error class
 */
export class ApiError extends Error {
  constructor(message, status, data = null) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.data = data;
  }
}

// Default HTTP client instance
export const httpClient = new HttpClient();
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Note title length validation

*For any* note creation or update request, the title field must be between 1 and 200 characters after whitespace stripping, and the API must return HTTP 422 with validation errors for titles outside this range.

**Validates: Requirements 5.2, 5.3, 5.8**

### Property 2: Note content length validation

*For any* note creation or update request, the content field must be between 1 and 10,000 characters after whitespace stripping, and the API must return HTTP 422 with validation errors for content outside this range.

**Validates: Requirements 5.4, 5.5, 5.8**

### Property 3: Whitespace stripping

*For any* note creation or update request with string fields containing leading or trailing whitespace, the API must strip the whitespace before validation and storage.

**Validates: Requirements 5.6**

### Property 4: Empty string rejection

*For any* note creation or update request with string fields that are empty or contain only whitespace after stripping, the API must reject the request with HTTP 422.

**Validates: Requirements 5.7**

### Property 5: Note creation round trip

*For any* valid note creation request, the created note must be retrievable via GET /notes/{id} with identical data.

**Validates: Requirements 8.2**

### Property 6: Note update preserves ID

*For any* valid note update request (PUT or PATCH), the updated note must retain its original ID and be retrievable with updated data.

**Validates: Requirements 8.4**

### Property 7: Note deletion removes record

*For any* valid note deletion request, the note must no longer be retrievable via GET /notes/{id} and must not appear in GET /notes list.

**Validates: Requirements 8.5**

### Property 8: Note listing includes all notes

*For any* set of created notes, the GET /notes endpoint must return all notes in the database, sorted by ID.

**Validates: Requirements 8.6**

### Property 9: Health check verifies database

*For any* call to the /health endpoint, the response must include HTTP 200 status if the database connection is available, and HTTP 500 if the database is unavailable.

**Validates: Requirements 10.6**

### Property 10: Startup retries database connection

*For any* application startup when the database is unavailable, the application must retry the database connection up to 5 times before exiting with an error.

**Validates: Requirements 10.2, 10.3**

### Property 11: Migration version tracking

*For any* applied migration, the alembic_version table must contain the migration revision hash, and the application must verify all migrations are applied at startup.

**Validates: Requirements 6.5, 6.7**

### Property 12: Exception handling logs stack trace

*For any* unhandled exception during request processing, the full stack trace must be logged and the client must receive HTTP 500 with a generic error message.

**Validates: Requirements 11.2, 11.3**

## Error Handling

### Validation Errors (HTTP 422)

Validation errors occur when request data fails Pydantic validation. The API returns detailed error messages indicating which fields failed validation and why.

**Example**:
```json
{
  "detail": [
    {
      "loc": ["body", "title"],
      "msg": "String should have at least 1 characters",
      "type": "string_too_short"
    }
  ]
}
```

### Not Found Errors (HTTP 404)

Not found errors occur when a requested resource doesn't exist. The API returns a clear error message indicating the resource type and ID.

**Example**:
```json
{
  "detail": "Note not found"
}
```

### Internal Server Errors (HTTP 500)

Internal server errors occur when an unhandled exception is raised. The API logs the full stack trace and returns a generic error message to the client.

**Example**:
```json
{
  "detail": "Internal server error"
}
```

### Database Errors

Database errors occur when the database connection fails or a query fails. The API handles these errors gracefully and returns appropriate HTTP status codes.

**Example**:
```json
{
  "detail": "Database connection failed"
}
```

## Testing Strategy

### Dual Testing Approach

The testing strategy uses both unit tests and property-based tests to ensure comprehensive coverage:

- **Unit tests**: Verify specific examples, edge cases, and error conditions
- **Property tests**: Verify universal properties across all inputs

Both approaches are complementary and necessary for robust validation.

### Unit Testing

Unit tests focus on specific examples and edge cases:

- **API endpoint tests**: Verify HTTP request/response behavior
- **Service layer tests**: Verify business logic in isolation
- **CRUD layer tests**: Verify database operations
- **Schema tests**: Verify Pydantic validation

**Test Organization**:
```
tests/
├── test_api/              # API endpoint tests
│   ├── test_notes.py      # Notes endpoint tests
│   └── test_admin.py      # Admin endpoint tests
└── test_service/          # Service layer tests
    └── test_notes.py      # Notes service tests
```

### Property-Based Testing

Property-based tests verify universal properties across all inputs:

- **Validation properties**: Test validation rules with random inputs
- **CRUD properties**: Test create/read/update/delete operations
- **Integration properties**: Test complete API workflows

**Property-Based Testing Library**: `fast-check` (Python) or `hypothesis` (Python)

**Configuration**:
- Minimum 100 iterations per property test
- Each test tagged with feature name and property number

**Example**:
```python
# tests/test_api/test_notes.py
import pytest
from fastapi.testclient import TestClient
import fastcheck

from app.main import app

client = TestClient(app)


@pytest.mark.property
def test_note_title_length_validation():
    """
    Feature: fastapi-production-restructure, Property 1: Note title length validation
    
    For any note creation request, the title field must be between 1 and 200 characters.
    """
    @fastcheck.property
    def property_title_length(title: str):
        if 1 <= len(title) <= 200:
            response = client.post("/notes", json={"title": title, "content": "test"})
            assert response.status_code == 201
        else:
            response = client.post("/notes", json={"title": title, "content": "test"})
            assert response.status_code == 422
    
    fastcheck.check(property_title_length)
```

### Test Database

A separate test database is used for end-to-end tests to avoid interfering with development data:

- **Test Database URL**: `postgresql://postgres:test@localhost:5432/notes_test`
- **Test Database Setup**: Created before tests, dropped after tests
- **Test Data Cleanup**: Truncated after each test

### Test Fixtures

Test fixtures provide reusable test data and setup:

```python
# tests/conftest.py
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.database import Base, get_db
from app.main import app

# Test database
TEST_DATABASE_URL = "postgresql://postgres:test@localhost:5432/notes_test"
engine = create_engine(TEST_DATABASE_URL)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(scope="function")
def db_session():
    """Create a database session for testing."""
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def test_client(db_session):
    """Create a test client with a database dependency override."""
    def override_get_db():
        try:
            yield db_session
        finally:
            pass
    
    app.dependency_overrides[get_db] = override_get_db
    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()
```

### Test Coverage

Tests cover the following areas:

- **API Endpoints**: All HTTP methods (GET, POST, PUT, PATCH, DELETE)
- **Validation**: All Pydantic validation rules
- **Error Handling**: All error responses (422, 404, 500)
- **Database Operations**: All CRUD operations
- **Service Logic**: All business logic
- **Integration**: Complete workflows from HTTP request to database response

### Test Execution

Tests are executed using pytest:

```bash
# Run all tests
pytest

# Run specific test file
pytest tests/test_api/test_notes.py

# Run property-based tests
pytest --property

# Run tests with coverage
pytest --cov=app --cov-report=html
```

### Frontend Testing

Frontend tests focus on JavaScript modules, DOM manipulation, and API integration using vanilla JavaScript testing approaches.

#### JavaScript Module Testing

Tests for individual JavaScript modules using Jest or similar testing framework:

- **API module tests**: Verify HTTP client functionality and error handling
- **UI module tests**: Verify DOM manipulation and event handling
- **Utils module tests**: Verify utility functions and helpers
- **Validation tests**: Verify form validation logic

**Test Organization**:
```
frontend/tests/
├── js/                    # JavaScript module tests
│   ├── api.test.js        # API module tests
│   ├── ui.test.js         # UI module tests
│   ├── utils.test.js      # Utils module tests
│   └── validation.test.js # Validation tests
├── fixtures/              # Test data and fixtures
│   ├── notes.json         # Sample note data
│   └── api-responses.json # Mock API responses
├── mocks/                 # Mock implementations
│   ├── fetch.js           # Fetch API mock
│   └── dom.js             # DOM API mocks
├── setup.js               # Test setup configuration
└── test-utils.js          # Testing utilities
```

#### Frontend Testing Framework Configuration

**Jest Configuration Example**:
```javascript
// frontend/jest.config.js
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  testMatch: ['<rootDir>/tests/**/*.test.js'],
  collectCoverageFrom: [
    'src/js/**/*.js',
    '!src/js/main.js',
    '!**/node_modules/**',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  transform: {
    '^.+\\.js$': 'babel-jest',
  },
};
```

#### Frontend Test Utilities and Setup

```javascript
// frontend/tests/setup.js
import 'jest-dom/extend-expect';

// Mock fetch globally
global.fetch = jest.fn();

// Mock localStorage
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
global.localStorage = localStorageMock;

// Clean up after each test
afterEach(() => {
  jest.clearAllMocks();
  document.body.innerHTML = '';
});
```

```javascript
// frontend/tests/test-utils.js
/**
 * Create mock note data for testing
 * @param {Object} overrides - Property overrides
 * @returns {Object} Mock note object
 */
export function createMockNote(overrides = {}) {
  return {
    id: 1,
    title: 'Test Note',
    content: 'Test content',
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
    ...overrides,
  };
}

/**
 * Create mock API response
 * @param {*} data - Response data
 * @param {number} status - HTTP status code
 * @returns {Object} Mock response object
 */
export function createMockResponse(data, status = 200) {
  return {
    ok: status >= 200 && status < 300,
    status,
    json: jest.fn().mockResolvedValue(data),
    text: jest.fn().mockResolvedValue(JSON.stringify(data)),
  };
}
```

#### Frontend Test Execution

Frontend tests are executed using npm scripts:

```bash
# Run all frontend tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage

# Run specific test file
npm test -- api.test.js
```
