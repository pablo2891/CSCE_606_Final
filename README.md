# LinkedOUT - Technical Documentation

LinkedOUT is a professional networking platform exclusively for Texas A&M University students and alumni to share job referrals, verify company employment, and connect through messaging. Built with **Ruby on Rails**, it features **company email verification**, **referral request management**, **real-time messaging**, and **comprehensive profile building**.

This document covers local setup, configuration, testing, deployment, and developer implementation details.

---

Deployed with Heroku: [https://linkedout-aggies-0f3d429fef3a.herokuapp.com/users/new](https://linkedout-aggies-0f3d429fef3a.herokuapp.com/users/new)

---

## Table of Contents
- [Quick Start (Local)](#quick-start-local)
- [Environment Variables & Credentials](#environment-variables--credentials)
- [Main User Flows](#main-user-flows)
- [Application Architecture](#application-architecture)
- [Testing & Quality Assurance](#testing--quality-assurance)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Developer Notes](#developer-notes)

---

## Quick Start (Local)

### Prerequisites
- Ruby (see `.ruby-version` or Gemfile)
- Bundler
- SQLite3 (development/test) / PostgreSQL (production)
- Node.js (for asset compilation)
- SMTP server access (Mailtrap recommended for development)

### Installation

Clone and set up the repository:
```bash
git clone <repository-url>
cd project3
bundle install
```

### Database Setup
```bash
bin/rails db:create db:migrate db:seed
```

### Configure Email Delivery (Required)

LinkedOUT requires email delivery for:
- TAMU email verification during signup
- Company email verification for posting referrals

Edit your development credentials:
```bash
# development environment
EDITOR="code --wait" bin/rails credentials:edit --environment development
```

Add the following structure with **your own** values:
```yaml
mailtrap:
  host: "sandbox.smtp.mailtrap.io"
  port: 2525
  username: "your-mailtrap-username"
  password: "your-mailtrap-password"
```

Alternatively, set environment variables:
```bash
export MAILTRAP_HOST="sandbox.smtp.mailtrap.io"
export MAILTRAP_PORT="2525"
export MAILTRAP_USERNAME="your-username"
export MAILTRAP_PASSWORD="your-password"
```

> **Important:** Never commit real credentials to git. Use Rails encrypted credentials or environment variables.

### Start the Application
```bash
bin/rails server
```

Access the app at: [http://localhost:3000](http://localhost:3000)

---

## Environment Variables & Credentials

### Required Credentials (Development)
| Key | Purpose |
|-----|----------|
| `mailtrap.host` / `mailtrap.username` / `mailtrap.password` | SMTP configuration for email verification |

### Optional Environment Variables
| Variable | Description |
|-----------|-------------|
| `DATABASE_URL` | Database connection string (production) |
| `RAILS_ENV` | Rails environment (`development` / `test` / `production`) |
| `PORT` | Custom server port (default 3000) |
| `MAILTRAP_INSECURE` | Set to `1` to disable SSL verification (dev only) |

### Example `.env.example`
```bash
# Copy to .env and fill in real values before running the app
MAILTRAP_HOST=sandbox.smtp.mailtrap.io
MAILTRAP_PORT=2525
MAILTRAP_USERNAME=your-username
MAILTRAP_PASSWORD=your-password
```

### Production Configuration

For production deployment, configure SMTP via production credentials or environment variables:
```bash
EDITOR="code --wait" bin/rails credentials:edit --environment production
```

Use a production email service (SendGrid, Mailgun, AWS SES, etc.) instead of Mailtrap.

---

## Main User Flows

### Authentication & User Management
- **Email/Password Registration:** Standard Rails authentication with `has_secure_password`.
- **TAMU Email Verification:** Users must verify `@tamu.edu` email via secure token link.
- **Session Management:** Cookie-based authentication with session storage.
- **Password Updates:** Requires current password verification for security.

### Company Verification
- **Company Email Verification:** Users submit work email for company domain matching.
- **Domain Validation:** Email domain must match company name (e.g., `@google.com` for "Google").
- **Verification Email:** Secure token link sent to company email.
- **Multiple Verifications:** Users can verify employment at multiple companies.
- **Verification Status:** Pending or Verified state tracking.

### Referral Post Management
- **Post Creation:** Only available for verified company users.
- **Custom Questions:** Posters can add up to 10 screening questions.
- **Post Status:** Active, Paused, or Closed states with enum management.
- **Search & Filtering:** Full-text search and advanced filtering by company, location, level, etc.
- **Post Ownership:** Edit/delete restricted to post creator.

### Referral Request System
- **Request Submission:** Users answer custom questions when requesting referrals.
- **Status Workflow:** Pending → Approved/Rejected/Withdrawn.
- **Automatic Post Closure:** Approving a request automatically closes the post.
- **Conversation Creation:** Approved requests trigger automatic conversation creation.
- **Request Uniqueness:** Users can only submit one request per post.

### Profile & Experience Management
- **Resume Upload:** PDF validation with 5MB size limit and Active Storage integration.
- **Experience Tracking:** JSONB storage for flexible work history.
- **Education Tracking:** JSONB storage for academic credentials.
- **Date Validation:** Ensures start dates precede end dates and don't exceed current date.
- **Verification Integration:** Link experiences to verified companies.

### Messaging System
- **Direct Conversations:** Between two users with automatic deduplication.
- **Subject Context:** Conversations linked to referral posts.
- **Message Threading:** Chronological message display with read status.
- **Auto-messaging:** System messages sent when requests are approved.
- **Access Control:** Only conversation participants can view/send messages.

### Dashboard & Analytics
- **Received Requests:** View and manage all incoming referral requests.
- **Sent Requests:** Track status of user's own applications.
- **Referral Browser:** Explore all active posts with comprehensive filtering.
- **Advanced Filters:** 10+ filter criteria including company, title, location, level, type, and date.
- **Request Status Management:** Inline status updates from dashboard.

---

## Application Architecture

### Core Models

#### User (`app/models/user.rb`)
- **Authentication:** `has_secure_password` with bcrypt.
- **TAMU Verification:** `has_secure_token :tamu_verification_token`.
- **Resume Storage:** Active Storage integration with PDF validation.
- **Relationships:**
  - `has_many :referral_posts` (as poster)
  - `has_many :referral_requests` (as requester)
  - `has_many :company_verifications`
- **JSONB Fields:** `experiences_data`, `educations_data` for flexible storage.
- **Validations:**
  - Email must end with `@tamu.edu`
  - Password minimum 6 characters
  - Resume must be PDF under 5MB

#### ReferralPost (`app/models/referral_post.rb`)
- **Relationships:**
  - `belongs_to :user` (poster)
  - `belongs_to :company_verification`
  - `has_many :referral_requests`
- **Status Enum:** `active: 0`, `paused: 1`, `closed: 2`.
- **Questions Field:** Array storage for custom screening questions (max 10).
- **Scopes:**
  - `active_posts`: Active posts ordered by creation date
  - `search(query)`: Case-insensitive search across company, title, department, location
- **Callbacks:** `normalize_questions` before save to clean array data.

#### ReferralRequest (`app/models/referral_request.rb`)
- **Relationships:**
  - `belongs_to :user` (requester)
  - `belongs_to :referral_post`
- **Status Enum:** `pending: 0`, `approved: 1`, `rejected: 2`, `withdrawn: 3`.
- **Submitted Data:** JSONB field storing question-answer pairs.
- **Uniqueness:** One request per user per post.
- **Methods:** `submitted_data_hash` returns normalized hash.

#### CompanyVerification (`app/models/company_verification.rb`)
- **Relationships:**
  - `belongs_to :user`
  - `has_many :referral_posts` (with `restrict_with_error`)
- **Verification Token:** `has_secure_token :verification_token`.
- **Validations:**
  - Company email must be valid email format
  - Unique per user (can't add same company email twice)
- **Email Domain Matching:** Controller validates domain matches company name.

#### Conversation (`app/models/conversation.rb`)
- **Relationships:**
  - `belongs_to :sender` (User)
  - `belongs_to :recipient` (User)
  - `has_many :messages`
- **Class Methods:**
  - `between(user_a_id, user_b_id)`: Find existing conversation
  - `find_or_create_between(user_a, user_b, subject)`: Deduplication logic
- **Instance Methods:**
  - `other_user(user)`: Returns the other participant

#### Message (`app/models/message.rb`)
- **Relationships:**
  - `belongs_to :conversation`
  - `belongs_to :user`
- **Validations:** Body presence required.
- **Callbacks:** `touch_conversation` after create to update conversation timestamp.

### Key Controllers

#### UsersController (`app/controllers/users_controller.rb`)
- **Actions:** `new`, `create`, `show`, `edit`, `update`
- **Experience CRUD:** `add_experience`, `create_experience`, `edit_experience`, `update_experience`, `delete_experience`
- **Education CRUD:** `add_education`, `create_education`, `edit_education`, `update_education`, `delete_education`
- **Authorization:** Users can only edit their own profiles.
- **Resume Management:** Purge and upload with Active Storage.
- **Date Validation:** Ensures experience/education dates are valid.

#### SessionsController (`app/controllers/sessions_controller.rb`)
- **Actions:** `new`, `create`, `destroy`
- **Login Logic:** Finds user by email and authenticates with `bcrypt`.
- **Session Management:** Stores `user_id` in session hash.
- **Redirect Logic:** Prevents logged-in users from accessing login page.

#### ReferralPostsController (`app/controllers/referral_posts_controller.rb`)
- **Actions:** Full CRUD with authorization checks.
- **Search & Filter:** Supports `query` parameter with case-insensitive matching.
- **Pagination:** Kaminari integration (5 posts per page).
- **Questions Management:** Normalizes array input from form fields.
- **Authorization:** Only post owner can edit/delete.
- **Error Handling:** `RecordNotFound` rescue with user-friendly redirect.

#### ReferralRequestsController (`app/controllers/referral_requests_controller.rb`)
- **Actions:** `show`, `create`, `update_status`, `create_from_message`
- **Status Updates:** Only post owner can update request status.
- **Post Closure Logic:** Approving closes post, reverting reopens it.
- **Conversation Creation:** Auto-creates conversation on approval.
- **Data Normalization:** Handles JSON, hash, and parameter formats.
- **Transaction Safety:** Uses `ActiveRecord::Base.transaction` for status changes.

#### CompanyVerificationsController (`app/controllers/company_verifications_controller.rb`)
- **Actions:** `new`, `create`, `verify`, `index`, `destroy`
- **Domain Validation:** `domain_matches_company?` helper method.
- **Email Delivery:** Triggers `CompanyMailer` on creation.
- **Verification Flow:** Token-based email confirmation.
- **Status Separation:** Separates pending and verified verifications in index.

#### DashboardController (`app/controllers/dashboard_controller.rb`)
- **Received Requests:** Joins through `referral_posts` owned by current user.
- **Sent Requests:** Direct association through current user.
- **Filtering Logic:** 10+ filter parameters with SQL queries.
- **Date Filtering:** Converts string options to time thresholds.
- **Status Filtering:** Enum-based status selection.
- **Search Queries:** Case-insensitive LIKE queries across multiple fields.

#### ConversationsController (`app/controllers/conversations_controller.rb`)
- **Actions:** `index`, `show`, `create`, `destroy`
- **Authorization:** Only participants can access conversations.
- **Message Marking:** Auto-marks messages as read when viewed.
- **Conversation Creation:** `find_or_create_between` deduplication.
- **Eager Loading:** Includes messages, sender, recipient to avoid N+1.

#### MessagesController (`app/controllers/messages_controller.rb`)
- **Actions:** `create` (nested under conversations)
- **Authorization:** Only conversation participants can send messages.
- **Touch Behavior:** Automatically updates conversation `updated_at`.

### Mailers

#### UserMailer (`app/mailers/user_mailer.rb`)
- **Method:** `tamu_verification_email`
- **Purpose:** Sends TAMU email verification link.
- **URL Generation:** Uses `verify_tamu_url` with secure token.

#### CompanyMailer (`app/mailers/company_mailer.rb`)
- **Method:** `company_verification_email`
- **Purpose:** Sends company email verification link.
- **URL Generation:** Uses `verify_company_verification_url` with secure token.

### Routes (`config/routes.rb`)

**Key Route Patterns:**
- **Nested Resources:** `referral_posts > referral_requests`
- **Member Routes:** Experience/education CRUD on users
- **Custom Actions:** `verify` on company verifications
- **Status Update:** Standalone PATCH route for request status
- **Messaging:** Nested messages under conversations
- **Email Verification:** GET routes with token parameters
- **Catch-all:** Fallback redirect for undefined routes

### Frontend Stack

- **Bootstrap 5** — Responsive grid and components
- **Custom TAMU Theme** (`app/assets/stylesheets/tamu-theme.css`) — Brand colors and utilities
- **Stimulus.js** — Lightweight JavaScript interactivity
- **Turbo Rails** — Fast navigation without full page reloads
- **Kaminari** — Pagination with custom TAMU styling

### Email Configuration

**Development (`config/environments/development.rb`):**
```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: Rails.application.credentials.dig(:mailtrap, :host),
  port: Rails.application.credentials.dig(:mailtrap, :port),
  user_name: Rails.application.credentials.dig(:mailtrap, :username),
  password: Rails.application.credentials.dig(:mailtrap, :password),
  authentication: :plain,
  enable_starttls_auto: true
}
```

**Production:** Configure with production SMTP service (SendGrid, AWS SES, etc.)

---

## Testing & Quality Assurance

### Test Stack
- **RSpec** — Unit and integration testing
- **Cucumber** — BDD feature testing
- **FactoryBot** — Test data generation
- **Capybara** — Browser simulation
- **SimpleCov** — Code coverage reporting

### Run Tests
```bash
# Run all RSpec tests
bundle exec rspec

# Run specific test suites
bundle exec rspec spec/models
bundle exec rspec spec/controllers
bundle exec rspec spec/requests

# Run Cucumber features
bundle exec cucumber

# Run with coverage
COVERAGE=true bundle exec rspec
COVERAGE=true bundle exec cucumber
```

### Coverage Strategy

**Model Specs:**
- Validations (email format, password length, uniqueness)
- Associations (belongs_to, has_many)
- Callbacks (before_save, after_create)
- Custom methods (full_name, submitted_data_hash)

**Controller Specs:**
- Authentication/authorization
- CRUD operations
- Parameter handling
- Flash messages
- Redirects

**Request Specs:**
- End-to-end user flows
- Multi-step processes (signup → verify → post)
- Error handling
- Session management

**Cucumber Features:**
- User signup and verification
- Company verification flow
- Creating referral posts
- Requesting and managing referrals
- Messaging between users
- Profile management

### Key Test Files
```
spec/
├── models/
│   ├── user_spec.rb
│   ├── referral_post_spec.rb
│   ├── referral_request_spec.rb
│   ├── company_verification_spec.rb
│   ├── conversation_spec.rb
│   └── message_spec.rb
├── controllers/
│   ├── users_controller_spec.rb
│   ├── sessions_controller_spec.rb
│   ├── referral_posts_controller_spec.rb
│   ├── referral_requests_controller_spec.rb
│   └── company_verifications_controller_spec.rb
└── requests/
    ├── authentication_spec.rb
    ├── referral_flow_spec.rb
    └── messaging_spec.rb

features/
├── user_authentication.feature
├── company_verification.feature
├── referral_posts.feature
├── referral_requests.feature
└── conversations.feature
```

### Test Environment Setup
```bash
# Prepare test database
RAILS_ENV=test bin/rails db:create db:migrate

# Reset test database
RAILS_ENV=test bin/rails db:reset
```

---

## Deployment

### Production Deployment (Heroku Example)
```bash
# Create Heroku app
heroku create linkedout-production

# Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# Set environment variables
heroku config:set RAILS_ENV=production
heroku config:set RAILS_MASTER_KEY=<your-master-key>

# Deploy
git push heroku main

# Run migrations
heroku run rails db:migrate

# Open app
heroku open
```

### Production Checklist

- [ ] Configure production SMTP credentials
- [ ] Set `RAILS_MASTER_KEY` environment variable
- [ ] Enable SSL (`force_ssl = true`)
- [ ] Set up PostgreSQL database
- [ ] Configure Active Storage (S3/CloudFront recommended)
- [ ] Set up background job processing (if needed)
- [ ] Configure DNS and SSL certificates
- [ ] Set up monitoring and error tracking
- [ ] Configure log aggregation
- [ ] Set up automated backups

### Database Migration

**SQLite to PostgreSQL:**
1. Export data with `rails db:seed:dump` or custom rake task
2. Update `database.yml` for PostgreSQL
3. Run `rails db:create db:migrate`
4. Import data or use production seeds

---

## Troubleshooting

### Email Delivery Issues

**Problem:** Verification emails not sending

**Solutions:**
```bash
# Check credentials
bin/rails credentials:show --environment development

# Test email in console
rails console
> UserMailer.with(user: User.first).tamu_verification_email.deliver_now

# Check Mailtrap inbox or logs
tail -f log/development.log
```

### Authentication Problems

**Problem:** Unable to log in after signup

**Solution:**
- Ensure user is created in database: `User.find_by(email: 'test@tamu.edu')`
- Check password encryption: `user.authenticate('password')`
- Verify session is being set: Check `session[:user_id]` in console

### Database Issues

**Problem:** Migration errors or data inconsistencies

**Solutions:**
```bash
# Reset database
bin/rails db:reset

# Check migration status
bin/rails db:migrate:status

# Rollback and remigrate
bin/rails db:rollback STEP=1
bin/rails db:migrate
```

### Asset Compilation

**Problem:** Stylesheets or JavaScript not loading

**Solutions:**
```bash
# Precompile assets
bin/rails assets:precompile

# Clear asset cache
bin/rails tmp:clear

# Check asset pipeline
bin/rails assets:environment
```

### Active Storage Issues

**Problem:** Resume uploads failing

**Solutions:**
- Check storage configuration in `config/storage.yml`
- Verify storage directory exists: `mkdir -p storage`
- Check file size: Max 5MB for resumes
- Ensure PDF format: Use `content_type` validation

---

## Developer Notes

### Company Verification System

**Email Domain Matching Logic:**
```ruby
def domain_matches_company?(verification)
  email_domain = verification.company_email.split("@").last.downcase
  company_domain = verification.company_name.parameterize.gsub("-", "")
  email_domain.include?(company_domain)
end
```

**Example:**
- Company: "Google" → Domain: "google"
- Email: "user@google.com" → Domain: "google.com"
- Match: (google is in google.com)

### JSONB Storage Pattern

**Experience/Education Data Structure:**
```ruby
{
  "title" => "Software Engineer",
  "company" => "Google",
  "start_date" => "2020-01-01",
  "end_date" => "2022-12-31",
  "description" => "Built awesome things"
}
```

**Benefits:**
- Flexible schema without migrations
- Fast queries with GIN indexes (PostgreSQL)
- Easy serialization/deserialization
- Backwards compatible

### Request Status Workflow
```
User submits request → PENDING
                          ↓
Poster reviews     → APPROVED → Post CLOSED → Conversation CREATED
                          ↓
                      REJECTED → Post remains ACTIVE
                          ↓
                      WITHDRAWN → Post remains ACTIVE
```

**Important:** Reverting from APPROVED to PENDING or REJECTED will reopen the post.

### Conversation Deduplication

**Logic:**
```ruby
def self.between(user_a_id, user_b_id)
  where("(sender_id = :a AND recipient_id = :b) OR (sender_id = :b AND recipient_id = :a)",
        a: user_a_id, b: user_b_id).limit(1).first
end
```

**Ensures:** Only one conversation exists between any two users, regardless of who initiated.

### Search & Filter Performance

**Optimizations:**
- Use database-level `LIKE` queries instead of Ruby filtering
- Eager load associations with `includes(:user, :referral_requests)`
- Paginate results with Kaminari
- Index frequently queried columns

**Indexes:**
```ruby
add_index :users, :email
add_index :referral_posts, :user_id
add_index :referral_posts, :status
add_index :referral_requests, [:user_id, :referral_post_id], unique: true
add_index :company_verifications, [:user_id, :company_name]
```

### Security Considerations

**Authentication:**
- BCrypt password hashing (cost factor 12)
- Secure token generation for email verification
- Session-based authentication with HTTP-only cookies

**Authorization:**
- Before action filters (`require_login`, `authorize_owner!`)
- Owner verification before edit/delete operations
- Conversation participant verification

**Data Validation:**
- Strong parameters in all controllers
- Model-level validations (presence, format, uniqueness)
- File upload restrictions (type, size)

**Email Security:**
- Unique verification tokens
- Time-limited tokens (implement expiration if needed)
- Domain validation for company emails

### Code Structure
```
app/
├── models/              # Core business logic
│   ├── user.rb
│   ├── referral_post.rb
│   ├── referral_request.rb
│   ├── company_verification.rb
│   ├── conversation.rb
│   └── message.rb
├── controllers/         # Request handling
│   ├── application_controller.rb
│   ├── users_controller.rb
│   ├── sessions_controller.rb
│   ├── referral_posts_controller.rb
│   ├── referral_requests_controller.rb
│   ├── company_verifications_controller.rb
│   ├── dashboard_controller.rb
│   ├── conversations_controller.rb
│   └── messages_controller.rb
├── mailers/            # Email delivery
│   ├── user_mailer.rb
│   └── company_mailer.rb
├── views/              # UI templates
│   ├── users/
│   ├── sessions/
│   ├── referral_posts/
│   ├── referral_requests/
│   ├── company_verifications/
│   ├── dashboard/
│   ├── conversations/
│   └── layouts/
├── helpers/            # View helpers
│   ├── application_helper.rb
│   └── company_verifications_helper.rb
└── assets/            # Stylesheets and JavaScript
    ├── stylesheets/
    │   ├── application.css.scss
    │   └── tamu-theme.css
    └── javascript/

config/
├── routes.rb          # URL routing
├── database.yml       # Database configuration
├── environments/      # Environment-specific settings
│   ├── development.rb
│   ├── test.rb
│   └── production.rb
└── credentials/       # Encrypted credentials
    ├── development.key
    └── development.yml.enc

db/
├── migrate/           # Database migrations
└── schema.rb          # Current database schema

spec/                  # RSpec tests
features/              # Cucumber scenarios
```

### Development Workflow

1. **Write Cucumber scenarios** for user-facing features
2. **Implement models** with validations and associations
3. **Write RSpec tests** for model logic
4. **Build controllers** with authorization
5. **Create views** with Bootstrap and TAMU theme
6. **Test end-to-end** with Cucumber
7. **Refactor** and optimize queries

### Common Patterns

**Controller Authorization:**
```ruby
before_action :require_login
before_action :set_resource, only: [:show, :edit, :update, :destroy]
before_action :authorize_owner!, only: [:edit, :update, :destroy]

def authorize_owner!
  unless @resource.user == current_user
    redirect_to root_path, alert: "Unauthorized"
  end
end
```

**Flash Messages:**
```ruby
# Success
redirect_to path, notice: "Action completed successfully!"

# Error
redirect_to path, alert: "Something went wrong."
flash.now[:error] = "Validation failed."
```

**Form Handling:**
```ruby
# Strong parameters
def resource_params
  params.require(:resource).permit(:field1, :field2, array_field: [])
end

# Nested attributes
params[:resource][:nested_array].map(&:to_s).reject(&:blank?)
```

### Future Enhancements

**Potential Features:**
- Email notifications for request status changes
- In-app notification system
- Advanced search with Elasticsearch
- Resume parsing and keyword matching
- Referral success tracking and analytics
- User reputation/rating system
- Integration with LinkedIn API
- Mobile responsive improvements
- Real-time messaging with Action Cable
- Export/import of profile data

**Technical Improvements:**
- Background job processing with Sidekiq
- Redis caching for dashboard queries
- Full-text search with pg_search
- GraphQL API for mobile apps
- WebSocket support for real-time updates
- Automated email reminders
- Token expiration for verification links
- Two-factor authentication

---

## Contributing Guidelines

- Follow Rails naming conventions
- Write tests before implementing features (TDD)
- Keep controllers thin, models fat
- Use service objects for complex business logic
- Document public methods and complex logic
- Use descriptive commit messages (Conventional Commits)
- Never commit credentials or secrets
- Run tests before submitting PRs
- Update documentation for new features

### Code Style
```ruby
def method(param:, optional: nil)
  # Implementation
end

# Prefer query methods over predicates
user.tamu_verified? # instead of user.is_tamu_verified == true

# Use early returns
return unless condition

# Chain queries clearly
User.where(verified: true)
    .includes(:posts)
    .order(created_at: :desc)
```

---