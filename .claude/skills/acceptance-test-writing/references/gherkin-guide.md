# Gherkin Syntax Reference Guide

## What is Gherkin?

Gherkin is a plain-text language with a simple structure designed to be easy to learn by non-programmers yet structured enough to allow concise description of test scenarios. It's the industry-standard format for writing acceptance tests in Behavior-Driven Development (BDD).

## Core Structure: Given-When-Then

The Given-When-Then format is the foundation of Gherkin syntax:

### **Given** (Preconditions)
Describes the initial context or state before an action occurs.

**Purpose:**
- Sets up the test scenario
- Establishes preconditions
- Describes the context in which the action happens

**Examples:**
```gherkin
Given the user is logged in
Given there are 5 items in the shopping cart
Given the database contains 100 products
Given the user has a premium subscription
Given the payment gateway is available
```

### **When** (Action/Trigger)
Describes the action or event that triggers the behavior being tested.

**Purpose:**
- Describes the specific action taken
- Should contain ONLY ONE trigger per scenario
- Represents the user's interaction or system event

**Examples:**
```gherkin
When the user clicks the "Submit" button
When the user enters "invalid@email" in the email field
When the payment is processed
When the session expires
When the user navigates to the checkout page
```

### **Then** (Expected Outcome)
Describes the expected result or observable outcome.

**Purpose:**
- Defines the expected behavior
- Specifies what should happen as a result
- Must be testable and verifiable

**Examples:**
```gherkin
Then the order confirmation page is displayed
Then an error message "Invalid email format" appears
Then the user receives a confirmation email
Then the item count updates to 6
Then the total price reflects the discount
```

## Extended Keywords

### **And** / **But**
Use these to add multiple conditions to Given, When, or Then clauses while maintaining readability.

```gherkin
Given the user is logged in
And the user has items in their cart
And the user has a valid payment method
When the user clicks "Place Order"
Then the order is created
And the user receives a confirmation email
And the inventory is updated
But the shopping cart is not emptied until payment confirms
```

### **Background**
Specifies steps that run before each scenario in a feature file. Use for common setup steps.

```gherkin
Feature: Shopping Cart

Background:
  Given the user is logged in
  And the user is on the products page

Scenario: Add item to cart
  When the user clicks "Add to Cart" on a product
  Then the cart count increases by 1
```

### **Scenario Outline** (with Examples)
Creates parameterized scenarios that run multiple times with different data.

```gherkin
Scenario Outline: User login with different credentials
  Given the user is on the login page
  When the user enters "<username>" and "<password>"
  Then the user should see "<message>"

  Examples:
    | username | password  | message                |
    | valid    | valid123  | Welcome Dashboard      |
    | invalid  | wrong     | Invalid credentials    |
    | admin    | admin123  | Admin Dashboard        |
```

## Complete Example

```gherkin
Feature: User Registration

Background:
  Given the registration page is accessible
  And the email service is available

Scenario: Successful registration with valid data
  Given the user is on the registration page
  And no account exists with email "newuser@example.com"
  When the user enters the following details:
    | Field            | Value                  |
    | Email            | newuser@example.com    |
    | Password         | SecurePass123!         |
    | Confirm Password | SecurePass123!         |
  And the user clicks "Create Account"
  Then the user is redirected to the welcome page
  And a confirmation email is sent to "newuser@example.com"
  And the account is created with "free" tier

Scenario: Registration fails with existing email
  Given an account already exists with email "existing@example.com"
  When the user attempts to register with "existing@example.com"
  Then the registration form displays "Email already registered"
  And the user remains on the registration page
  And no new account is created
```

## Gherkin Best Practices

### 1. Use Domain Language
Write scenarios using the language of the business domain, not technical implementation:

**Good:**
```gherkin
When the user submits the order
Then the order confirmation is displayed
```

**Bad:**
```gherkin
When the user sends a POST request to /api/orders
Then the HTTP response code is 201
```

### 2. One Behavior Per Scenario
Each scenario should test a single, specific behavior:

**Good:**
```gherkin
Scenario: Add item to empty cart
  Given the cart is empty
  When the user adds a product
  Then the cart contains 1 item
```

**Bad:**
```gherkin
Scenario: Complete shopping workflow
  Given the user is logged in
  When the user adds items, updates quantities, applies coupon, and checks out
  Then everything works correctly
```

### 3. Keep Scenarios Independent
Each scenario should be able to run independently without depending on other scenarios.

### 4. Use Concrete Examples
Avoid vague terms; use specific, concrete examples:

**Good:**
```gherkin
Given the product price is $50.00
And the discount is 20%
Then the final price should be $40.00
```

**Bad:**
```gherkin
Given the product has a price
And there is some discount
Then the price should be reduced
```

### 5. Focus on "What," Not "How"
Describe what should happen, not how it should be implemented:

**Good:**
```gherkin
When the user updates their profile
Then the changes are saved
```

**Bad:**
```gherkin
When the user clicks the save button which triggers a PUT request to update the database
Then the profile table row is updated
```

## Common Gherkin Keywords Reference

| Keyword          | Purpose                                      | Position              |
|------------------|----------------------------------------------|-----------------------|
| Feature          | High-level description of functionality      | File header           |
| Background       | Steps that run before each scenario          | Before scenarios      |
| Scenario         | Concrete example of business rule            | Main test case        |
| Scenario Outline | Template scenario with examples              | Parameterized test    |
| Given            | Preconditions and initial context            | Setup                 |
| When             | Action or event                              | Trigger               |
| Then             | Expected outcome                             | Verification          |
| And              | Additional step (continues previous keyword) | Any clause            |
| But              | Additional step (negative continuation)      | Any clause            |
| Examples         | Data table for Scenario Outline              | After Scenario Outline|

## Automation Integration

While Gherkin is human-readable, it's designed to be automatable with tools like:

- **Cucumber** (Ruby, Java, JavaScript, etc.)
- **SpecFlow** (.NET)
- **Behave** (Python)
- **Playwright + Cucumber** (JavaScript/TypeScript)
- **Robot Framework**

The Gherkin syntax remains the same regardless of the automation tool.
