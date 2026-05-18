# Acceptance Criteria Template

Use this template as a starting point for writing acceptance criteria for your user stories.

---

## User Story Template

```
**As a** [role/persona]
**I want to** [goal/desire]
**So that** [benefit/value]
```

**Example:**
```
**As a** customer
**I want to** filter products by price range
**So that** I can find items within my budget
```

---

## Acceptance Criteria Format Options

Choose the format that best fits your scenario:

### Option 1: Given-When-Then (Scenario-Oriented)

**Best for:** Behavior-driven development (BDD), user interactions, workflows

```gherkin
Scenario: [Brief description of the scenario]
  Given [precondition/context]
  And [additional precondition, if needed]
  When [action/trigger]
  Then [expected outcome]
  And [additional expected outcome, if needed]
```

**Example:**
```gherkin
Scenario: Filter products by price range
  Given the catalog contains 100 products
  And products range in price from $10 to $500
  When the user sets price filter to "$50-$100"
  Then only products priced between $50 and $100 are displayed
  And the product count shows "15 products"
  And the filter tag "$50-$100" is visible
```

---

### Option 2: Rule-Oriented (Checklist)

**Best for:** Validation rules, requirements lists, system constraints

```
Acceptance Criteria:
- [Criterion 1]
- [Criterion 2]
- [Criterion 3]
...
```

**Example:**
```
Acceptance Criteria:
- Price range slider displays minimum ($10) and maximum ($500) values
- User can adjust both minimum and maximum values
- Results update in real-time as slider is adjusted
- Price range is inclusive (includes min and max values)
- URL updates with filter parameters for bookmarking
- Filter persists when user navigates away and returns
```

---

## Writing Checklist

Before finalizing acceptance criteria, verify:

### ✅ Quality Checks
- [ ] **Testable** - Can be verified with clear pass/fail outcome
- [ ] **Clear** - No ambiguity or room for interpretation
- [ ] **Specific** - Uses concrete examples and values
- [ ] **Independent** - Can be tested separately from other scenarios
- [ ] **User-Focused** - Written from user's perspective
- [ ] **Complete** - Covers happy path, error cases, and edge cases

### ✅ Format Checks
- [ ] Uses active voice (not passive)
- [ ] Uses domain language (not technical implementation)
- [ ] One trigger per When clause (for Given-When-Then)
- [ ] Each scenario tests one behavior
- [ ] Avoids UI element references (button IDs, CSS classes, etc.)
- [ ] Avoids technical details (APIs, database tables, etc.)

### ✅ Coverage Checks
- [ ] Happy path scenario included
- [ ] Error/failure scenarios included
- [ ] Edge cases and boundary conditions included
- [ ] User permissions/authorization considered
- [ ] Performance requirements specified (if applicable)
- [ ] Accessibility requirements specified (if applicable)

---

## Complete Example

### User Story: Product Search

```
**As a** customer
**I want to** search for products
**So that** I can quickly find what I'm looking for
```

### Acceptance Criteria

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
  And the user can clear the search to see all products

Scenario: Empty search query
  Given the user is on the search page
  When the user submits an empty search query
  Then an error message "Please enter a search term" appears
  And no search is performed
  And the search input field is highlighted

Scenario: Search with special characters
  Given the catalog contains products
  When the user searches for "C# programming"
  Then special characters are properly handled
  And results include products matching "C#" or "C sharp"
  And no error occurs

Scenario: Search with very long query
  Given the user is on the search page
  When the user enters a search query longer than 200 characters
  Then the query is truncated to 200 characters
  And a warning "Search limited to 200 characters" is displayed
  And the search proceeds with truncated query
```

---

## Tips for Effective Acceptance Criteria

### DO:
✅ Write from the user's perspective
✅ Use concrete, specific examples
✅ Cover positive and negative cases
✅ Make criteria independently testable
✅ Use domain language everyone understands
✅ Keep scenarios focused on one behavior
✅ Include measurable performance criteria when relevant

### DON'T:
❌ Reference UI elements (button IDs, CSS classes)
❌ Specify technical implementation (API endpoints, database queries)
❌ Use vague terms ("properly", "correctly", "quickly")
❌ Test multiple behaviors in one scenario
❌ Write more than 6-10 criteria per user story
❌ Create dependencies between scenarios
❌ Omit error cases and edge conditions

---

## Quick Start Template

Copy and customize this template:

```
### User Story: [Story Name]

**As a** [role]
**I want to** [goal]
**So that** [benefit]

### Acceptance Criteria

Scenario: [Happy path - successful case]
  Given [initial context]
  When [user action]
  Then [expected result]

Scenario: [Error case - what goes wrong]
  Given [initial context]
  When [action that causes error]
  Then [error handling behavior]

Scenario: [Edge case - boundary condition]
  Given [edge case context]
  When [action at boundary]
  Then [expected boundary behavior]
```

---

## Resources

For more detailed guidance, refer to:
- **Gherkin Syntax Guide** - Complete reference for Given-When-Then format
- **Anti-Patterns Guide** - Common mistakes to avoid
- **Examples Library** - Real-world examples across different domains

---

**Remember:** Good acceptance criteria are a shared understanding between developers, testers, and business stakeholders. They should be clear enough that anyone on the team can verify whether the story is "done."
