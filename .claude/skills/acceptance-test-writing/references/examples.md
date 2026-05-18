# Acceptance Criteria Examples

Real-world examples of well-written acceptance criteria across different domains and scenarios.

---

## E-Commerce Examples

### User Story: Product Search
**As a** customer
**I want to** search for products
**So that** I can quickly find what I'm looking for

#### Acceptance Criteria (Given-When-Then):

```gherkin
Scenario: Search returns relevant results
  Given the catalog contains 1000 products
  And 10 products contain "wireless headphones" in their name or description
  When the user searches for "wireless headphones"
  Then the search results display the 10 matching products
  And the results are sorted by relevance
  And the search completes in under 1 second

Scenario: Search with no results
  Given the catalog contains 1000 products
  And no products match "xyznonexistent"
  When the user searches for "xyznonexistent"
  Then the message "No products found for 'xyznonexistent'" is displayed
  And suggestions for similar searches are shown

Scenario: Empty search query
  Given the user is on the search page
  When the user submits an empty search query
  Then an error message "Please enter a search term" appears
  And no search is performed
```

---

### User Story: Shopping Cart Total Calculation
**As a** customer
**I want to** see accurate cart totals
**So that** I know exactly how much I'll pay

#### Acceptance Criteria (Given-When-Then):

```gherkin
Scenario: Calculate cart total with multiple items
  Given the cart contains:
    | Product   | Quantity | Unit Price |
    | Laptop    | 1        | $1200.00   |
    | Mouse     | 2        | $25.00     |
    | Keyboard  | 1        | $75.00     |
  When the cart total is calculated
  Then the subtotal is $1325.00
  And the tax (8%) is $106.00
  And the shipping is $15.00
  And the grand total is $1446.00

Scenario: Apply discount coupon
  Given the cart subtotal is $100.00
  And a coupon "SAVE20" exists with 20% off
  When the user applies coupon "SAVE20"
  Then the discount is $20.00
  And the new subtotal is $80.00
  And the coupon status shows "Applied: SAVE20"

Scenario: Invalid coupon code
  Given the cart subtotal is $100.00
  And no coupon "INVALID" exists
  When the user applies coupon "INVALID"
  Then an error message "Invalid coupon code" is displayed
  And no discount is applied
  And the subtotal remains $100.00
```

---

## Authentication & Authorization Examples

### User Story: User Login
**As a** registered user
**I want to** log into my account
**So that** I can access my personalized content

#### Acceptance Criteria (Given-When-Then):

```gherkin
Scenario: Successful login with valid credentials
  Given a user account exists with email "user@example.com" and password "SecurePass123"
  And the user is on the login page
  When the user enters email "user@example.com"
  And the user enters password "SecurePass123"
  And the user clicks "Login"
  Then the user is redirected to the dashboard
  And the welcome message shows "Welcome back, John"
  And the session is established

Scenario: Failed login with incorrect password
  Given a user account exists with email "user@example.com"
  When the user enters email "user@example.com"
  And the user enters password "WrongPassword"
  And the user clicks "Login"
  Then the error message "Invalid email or password" is displayed
  And the user remains on the login page
  And no session is established

Scenario: Account lockout after failed attempts
  Given a user account exists with email "user@example.com"
  And the account has 2 previous failed login attempts
  When the user enters incorrect credentials
  And the user clicks "Login"
  Then the account is locked for 15 minutes
  And the message "Account temporarily locked. Try again in 15 minutes" is displayed
  And a security notification email is sent to the user
```

---

### User Story: Password Reset
**As a** user who forgot their password
**I want to** reset my password
**So that** I can regain access to my account

#### Acceptance Criteria (Given-When-Then):

```gherkin
Scenario: Request password reset for existing account
  Given an account exists with email "user@example.com"
  When the user requests a password reset for "user@example.com"
  Then a password reset email is sent to "user@example.com"
  And the message "Password reset instructions sent to your email" is displayed
  And the reset link expires in 1 hour

Scenario: Request password reset for non-existent account
  Given no account exists with email "unknown@example.com"
  When the user requests a password reset for "unknown@example.com"
  Then the generic message "If an account exists, reset instructions were sent" is displayed
  And no email is sent
  But the system does not reveal that the account doesn't exist

Scenario: Reset password with valid token
  Given the user has a valid password reset token
  When the user enters new password "NewSecurePass456"
  And the user confirms password "NewSecurePass456"
  And the user submits the reset form
  Then the password is updated
  And all existing sessions are invalidated
  And the user is redirected to login page
  And the message "Password successfully reset. Please login" is displayed
```

---

## Form Validation Examples

### User Story: Contact Form Submission
**As a** website visitor
**I want to** submit a contact form
**So that** I can reach the support team

#### Acceptance Criteria (Given-When-Then):

```gherkin
Scenario: Submit form with all valid data
  Given the user is on the contact form page
  When the user enters:
    | Field   | Value                           |
    | Name    | John Doe                        |
    | Email   | john@example.com                |
    | Subject | Product inquiry                 |
    | Message | I have a question about pricing |
  And the user clicks "Submit"
  Then the form is submitted successfully
  And the confirmation message "Thank you! We'll respond within 24 hours" appears
  And a confirmation email is sent to "john@example.com"
  And the form fields are cleared

Scenario: Submit form with invalid email
  Given the user is on the contact form page
  When the user enters email "notanemail"
  And the user attempts to submit
  Then the form is not submitted
  And the error "Please enter a valid email address" appears next to email field
  And the email field is highlighted

Scenario: Submit form with missing required fields
  Given the user is on the contact form page
  When the user leaves the "Name" field empty
  And the user attempts to submit
  Then the form is not submitted
  And the error "Name is required" appears next to the name field
  And the name field is highlighted
```

---

## API & Integration Examples

### User Story: Third-Party Payment Processing
**As a** customer
**I want to** pay with my credit card
**So that** I can complete my purchase

#### Acceptance Criteria (Given-When-Then):

```gherkin
Scenario: Successful payment processing
  Given the user has items in cart worth $150.00
  And the payment gateway is available
  And the user's card has sufficient funds
  When the user enters valid card details:
    | Card Number      | 4111111111111111 |
    | Expiry           | 12/25            |
    | CVV              | 123              |
    | Billing ZIP      | 12345            |
  And the user clicks "Pay Now"
  Then the payment is processed successfully
  And the order status becomes "Confirmed"
  And the user receives order confirmation email
  And the inventory is decremented

Scenario: Payment declined by processor
  Given the user has items in cart worth $150.00
  And the payment gateway is available
  And the user's card is declined (insufficient funds)
  When the user submits payment
  Then the payment fails
  And the error "Payment declined. Please use a different card" is displayed
  And the order is not created
  And the inventory is not decremented

Scenario: Payment gateway unavailable
  Given the user has items in cart worth $150.00
  And the payment gateway is unavailable
  When the user attempts to submit payment
  Then the error "Payment service temporarily unavailable. Please try again" is displayed
  And the user can retry the payment
  And the order remains in "Pending Payment" status
```

---

## Data Management Examples

### User Story: File Upload
**As a** user
**I want to** upload a profile photo
**So that** I can personalize my account

#### Acceptance Criteria (Given-When-Then):

```gherkin
Scenario: Upload valid image file
  Given the user is on the profile settings page
  And the user has a valid image file (photo.jpg, 2MB, JPEG format)
  When the user selects the image file
  And the user clicks "Upload"
  Then the image is uploaded successfully
  And the profile photo is updated with the new image
  And the message "Profile photo updated successfully" appears
  And the file is stored in the user's media library

Scenario: Reject file exceeding size limit
  Given the user is on the profile settings page
  And the user has an image file (large.jpg, 15MB, JPEG format)
  When the user attempts to upload the file
  Then the upload is rejected
  And the error "File size exceeds 10MB limit" is displayed
  And the current profile photo remains unchanged

Scenario: Reject invalid file format
  Given the user is on the profile settings page
  And the user has a PDF file (document.pdf)
  When the user attempts to upload the file
  Then the upload is rejected
  And the error "Only JPG, PNG, and GIF formats are supported" is displayed
  And suggested formats are shown
```

---

## Reporting & Analytics Examples

### User Story: Sales Report Generation
**As a** sales manager
**I want to** generate monthly sales reports
**So that** I can analyze performance

#### Acceptance Criteria (Given-When-Then):

```gherkin
Scenario: Generate report for specific month
  Given the system has sales data for January 2025
  And the sales data includes:
    | Total Orders | 1250   |
    | Total Revenue| $45000 |
    | Top Product  | Widget |
  When the user selects "January 2025"
  And the user clicks "Generate Report"
  Then the report is generated within 5 seconds
  And the report shows total orders of 1250
  And the report shows total revenue of $45000
  And the report shows Widget as top product
  And the report can be exported as PDF or Excel

Scenario: Generate report with no data
  Given the system has no sales data for February 2025
  When the user selects "February 2025"
  And the user clicks "Generate Report"
  Then the message "No sales data available for February 2025" is displayed
  And an empty report template is shown
  And the user can select a different date range

Scenario: Filter report by product category
  Given a sales report is displayed for January 2025
  When the user applies filter "Category: Electronics"
  Then the report updates to show only Electronics sales
  And the filtered totals are recalculated
  And the filter tag "Category: Electronics" is displayed
  And the filter can be removed to show all data again
```

---

## Notification & Communication Examples

### User Story: Email Notifications
**As a** user
**I want to** receive order status notifications
**So that** I stay informed about my orders

#### Acceptance Criteria (Given-When-Then):

```gherkin
Scenario: Send order confirmation email
  Given the user places an order with order ID #12345
  And the user's email is "customer@example.com"
  When the order is successfully created
  Then a confirmation email is sent to "customer@example.com" within 1 minute
  And the email subject is "Order Confirmation - #12345"
  And the email contains:
    | Order Number      | #12345                  |
    | Order Total       | $150.00                 |
    | Estimated Delivery| 3-5 business days       |
    | Items List        | Complete order details  |
  And the email includes a tracking link

Scenario: Send shipping notification
  Given an order #12345 has status "Confirmed"
  When the order status changes to "Shipped"
  And a tracking number "1Z999AA10123456784" is assigned
  Then a shipping notification email is sent
  And the email contains tracking number "1Z999AA10123456784"
  And the email includes a tracking link to the carrier's website

Scenario: Respect notification preferences
  Given the user has disabled "Marketing emails" in preferences
  And the user has enabled "Order updates" in preferences
  When a marketing campaign is launched
  Then no marketing email is sent to the user
  But order-related emails are still sent
```

---

## Rule-Oriented Format Examples

Sometimes the Given-When-Then format isn't the best fit. Here are examples using rule-oriented acceptance criteria:

### User Story: User Registration
**As a** new visitor
**I want to** create an account
**So that** I can save my preferences

#### Acceptance Criteria (Rule-Oriented):

- Email address must be unique (not already registered)
- Password must be at least 8 characters long
- Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character
- User must accept terms of service before registration
- Confirmation email must be sent to the provided email address within 1 minute
- User account is created with "unverified" status until email is confirmed
- User cannot login until email is verified

---

### User Story: Discount Code Validation
**As a** customer
**I want to** apply discount codes at checkout
**So that** I can save money on my purchase

#### Acceptance Criteria (Rule-Oriented):

- Discount code must be case-insensitive
- Discount code must be currently active (within valid date range)
- Discount code usage must not exceed the maximum usage limit
- User can only apply one discount code per order
- Discount must apply to eligible items only (based on code rules)
- Minimum order value requirement must be met (if specified for the code)
- Discount amount must be calculated correctly (percentage or fixed amount)
- If code is invalid, a clear error message must explain why

---

## Accessibility Examples

### User Story: Keyboard Navigation
**As a** keyboard-only user
**I want to** navigate the site using keyboard
**So that** I can use the site without a mouse

#### Acceptance Criteria (Given-When-Then):

```gherkin
Scenario: Navigate through form fields with Tab key
  Given the user is on the registration form
  When the user presses Tab key
  Then focus moves to the next form field in logical order
  And focus indicator is clearly visible
  And the tab order follows the visual layout

Scenario: Submit form with Enter key
  Given the user has completed all required fields
  And the cursor is in any form field
  When the user presses Enter key
  Then the form is submitted
  And validation runs before submission

Scenario: Close modal with Escape key
  Given a modal dialog is open
  When the user presses Escape key
  Then the modal closes
  And focus returns to the element that opened the modal
```

---

## Performance & Load Examples

### User Story: Page Load Performance
**As a** user
**I want to** pages to load quickly
**So that** I have a smooth experience

#### Acceptance Criteria (Rule-Oriented):

- Home page must load in under 2 seconds on 3G connection
- Time to First Contentful Paint (FCP) must be under 1.5 seconds
- Time to Interactive (TTI) must be under 3 seconds
- Largest Contentful Paint (LCP) must be under 2.5 seconds
- Cumulative Layout Shift (CLS) must be under 0.1
- Images must be lazy-loaded below the fold
- Critical CSS must be inlined
- JavaScript bundles must be code-split by route

---

These examples demonstrate how acceptance criteria should be:
- **Specific and measurable**
- **Focused on user behavior**
- **Independent and testable**
- **Cover happy paths and edge cases**
- **Written in domain language**
- **Free from implementation details**
