# Acceptance Criteria Anti-Patterns

This guide identifies common mistakes when writing acceptance criteria and how to avoid them.

## 1. Implementation-Focused Criteria

### ❌ Bad: Specifying Technical Implementation
```gherkin
Given the user is authenticated with JWT token
When a POST request is sent to /api/orders with JSON payload
Then the database record is inserted with status "pending"
And a 201 HTTP response is returned
```

### ✅ Good: Focusing on User Behavior
```gherkin
Given the user is logged in
When the user places an order
Then the order is created with "pending" status
And the user sees an order confirmation
```

**Why:** Acceptance criteria should describe WHAT happens from the user's perspective, not HOW it's implemented. Technical details tie the requirements to specific implementation choices.

---

## 2. UI Element Coupling

### ❌ Bad: Referencing Specific UI Elements
```gherkin
Given the user clicks the blue "Submit" button in the top-right corner
When the modal dialog appears with id "confirmation-popup"
Then the success message displays in the div with class "alert-success"
```

### ✅ Good: Describing User Actions
```gherkin
Given the user submits the form
When the confirmation prompt appears
Then a success message is displayed
```

**Why:** UI elements (colors, positions, IDs, classes) change frequently. Acceptance criteria should survive UI redesigns.

---

## 3. Vague or Ambiguous Language

### ❌ Bad: Using Unclear Terms
```gherkin
Given the system is ready
When the user does something with the product
Then the appropriate response happens quickly
And the data is properly handled
```

### ✅ Good: Being Specific and Measurable
```gherkin
Given the inventory system is available
When the user adds a product to their cart
Then the cart updates within 2 seconds
And the product quantity decreases by 1
```

**Why:** Terms like "ready," "properly," "quickly," "appropriate" are subjective and not testable.

---

## 4. Multiple Behaviors in One Scenario

### ❌ Bad: Testing Everything at Once
```gherkin
Scenario: User completes entire shopping experience
  Given the user browses products
  When they add items, update quantities, apply coupons, checkout, and confirm payment
  Then everything works correctly
  And the user is happy
```

### ✅ Good: One Behavior Per Scenario
```gherkin
Scenario: Apply discount coupon to cart
  Given the cart contains items worth $100
  And a "SAVE20" coupon exists with 20% discount
  When the user applies coupon "SAVE20"
  Then the cart total becomes $80
  And the discount line item shows "-$20"
```

**Why:** One scenario should test one specific behavior. Multiple behaviors make debugging difficult and scenarios fragile.

---

## 5. Multiple Triggers in When Clause

### ❌ Bad: Multiple Actions in When
```gherkin
When the user logs in and navigates to dashboard and clicks on profile
Then the profile page is displayed
```

### ✅ Good: Single Trigger
```gherkin
Given the user is logged in
And the user is on the dashboard
When the user clicks on their profile
Then the profile page is displayed
```

**Why:** The When clause should contain exactly ONE trigger. Multiple actions belong in Given or should be separate scenarios.

---

## 6. Using Passive Voice

### ❌ Bad: Passive Voice
```gherkin
Given the form is filled out by the user
When the submit button is clicked
Then the data is validated by the system
And the user is redirected to the confirmation page
```

### ✅ Good: Active Voice
```gherkin
Given the user fills out the form
When the user clicks submit
Then the system validates the data
And the user sees the confirmation page
```

**Why:** Active voice is clearer and more direct. It makes it obvious who/what is performing the action.

---

## 7. Negative Sentences

### ❌ Bad: Using "Not" Statements
```gherkin
Given the user is not logged out
When the user does not enter an invalid email
Then the error message should not be hidden
And the form should not fail to submit
```

### ✅ Good: Positive Statements
```gherkin
Given the user is logged in
When the user enters a valid email
Then no error message appears
And the form submits successfully
```

**Why:** Double negatives and "not" statements create confusion. Frame criteria positively when possible.

---

## 8. Too Many Acceptance Criteria

### ❌ Bad: User Story with 15 Acceptance Criteria
```
User Story: As a user, I want to manage my account

Acceptance Criteria:
1. User can update email
2. User can update password
3. User can update phone number
4. User can update address
5. User can update billing info
6. User can update preferences
7. User can update notification settings
8. User can upload profile photo
9. User can delete profile photo
10. User can view account history
11. User can download account data
12. User can close account
13. User can reactivate account
14. User can link social accounts
15. User can unlink social accounts
```

### ✅ Good: Split into Multiple, Focused Stories
```
Story 1: Update Contact Information
- User can update email address
- User can update phone number
- User can update mailing address

Story 2: Manage Profile Photo
- User can upload a new profile photo
- User can delete existing profile photo

Story 3: Account Security
- User can update password
- User can enable two-factor authentication
```

**Why:** Stories with more than 6-10 acceptance criteria are too large and should be split.

---

## 9. Testing Instead of Specifying

### ❌ Bad: Writing Test Steps
```gherkin
When I enter "test@example.com" in field id="email"
And I enter "password123" in field id="password"
And I click button id="submit"
And I wait 2 seconds
Then I should see element with class "success"
```

### ✅ Good: Specifying Expected Behavior
```gherkin
When the user logs in with valid credentials
Then the user accesses their dashboard
And a welcome message is displayed
```

**Why:** Acceptance criteria specify WHAT should happen, not detailed test steps. Test automation handles the HOW.

---

## 10. Omitting Important Context

### ❌ Bad: Missing Preconditions
```gherkin
When the user clicks "Delete"
Then the item is removed
```

### ✅ Good: Complete Context
```gherkin
Given the user has "Editor" permissions
And the item is in "draft" status
When the user clicks "Delete"
Then the item is moved to trash
And the user sees "Item deleted" confirmation
```

**Why:** Without proper context, the scenario is incomplete and may be misunderstood.

---

## 11. Non-Testable Criteria

### ❌ Bad: Cannot Be Verified
```gherkin
Then the user experience is improved
And the system feels faster
And the design looks better
And users are more satisfied
```

### ✅ Good: Measurable and Testable
```gherkin
Then the page loads in under 2 seconds
And the layout matches the approved design mockup
And all elements are properly aligned
And the user satisfaction score increases by 10%
```

**Why:** Every acceptance criterion must be testable with a clear pass/fail outcome.

---

## 12. Technology or Framework Specific

### ❌ Bad: Coupled to Technology
```gherkin
Given the React component is mounted
When the Redux action LOGIN_SUCCESS is dispatched
Then the component state updates
And useEffect hook triggers re-render
```

### ✅ Good: Technology Agnostic
```gherkin
Given the user provides valid login credentials
When the user logs in successfully
Then the user's session is established
And the user interface updates to show logged-in state
```

**Why:** Acceptance criteria should survive technology changes. They describe business requirements, not implementation.

---

## 13. Dependent Scenarios

### ❌ Bad: Scenarios Depend on Each Other
```gherkin
Scenario: Create user account
  When I create account "john@example.com"
  Then account is created

Scenario: Login with created account (depends on previous scenario!)
  When I login as "john@example.com"
  Then I see dashboard
```

### ✅ Good: Independent Scenarios
```gherkin
Scenario: Create user account
  Given no account exists for "john@example.com"
  When I create account "john@example.com"
  Then account is created

Scenario: Login with existing account
  Given an account exists for "john@example.com"
  When I login as "john@example.com"
  Then I see dashboard
```

**Why:** Each scenario must be independently executable in any order.

---

## 14. Missing Edge Cases

### ❌ Bad: Only Happy Path
```gherkin
Scenario: User login
  When user enters username and password
  Then user is logged in
```

### ✅ Good: Include Edge Cases and Error Scenarios
```gherkin
Scenario: Successful login with valid credentials
  Given the user has an active account
  When the user enters correct username and password
  Then the user is logged in

Scenario: Login fails with incorrect password
  Given the user has an active account
  When the user enters correct username but wrong password
  Then login fails with "Invalid credentials" message
  And the user remains on login page

Scenario: Login blocked after 3 failed attempts
  Given the user has failed login 3 times
  When the user attempts to login again
  Then the account is temporarily locked
  And the user sees "Account locked for 15 minutes" message
```

**Why:** Acceptance criteria should cover success cases, error cases, edge cases, and boundary conditions.

---

## Quick Reference: Signs of Bad Acceptance Criteria

- ❌ References UI elements (buttons, divs, IDs, classes)
- ❌ Mentions technical implementation (APIs, databases, HTTP codes)
- ❌ Uses vague terms ("properly," "quickly," "correctly")
- ❌ Tests multiple behaviors in one scenario
- ❌ Has multiple When clauses
- ❌ Written in passive voice
- ❌ Uses negative statements excessively
- ❌ Cannot be tested with clear pass/fail
- ❌ Depends on other scenarios
- ❌ Omits important context or edge cases
- ❌ More than 6-10 criteria per user story

## Quick Reference: Signs of Good Acceptance Criteria

- ✅ Describes user behavior and outcomes
- ✅ Uses domain language
- ✅ Specific and measurable
- ✅ One behavior per scenario
- ✅ Single trigger in When clause
- ✅ Written in active voice
- ✅ Testable with clear pass/fail
- ✅ Independent and self-contained
- ✅ Includes relevant context
- ✅ Covers happy path, errors, and edge cases
