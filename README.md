# Client Order Management System

## 1. System Overview & Data Architecture
**Tables: :** 
* **Clients :** Stores the list of all clients with additional info like email, loyality level.
* **Articles:** Stores the catalog of available products/items.
* **Prices :** Stores current pricing mapped to specific articles.
* **Orders :** Records submitted client orders, referencing the selected articles and their respective prices at the time of purchase.

---

## 2. Current Functionality (MVP)

### Use Case: Create a Single-Item Order
* **Actor:** Client
* **Preconditions:** The client has access to the order entry interface.
* **Workflow:**
  1. The client locates and selects their name from a dropdown (combo box) list.
  2. Upon selection, the order creation controls become active.
  3. The client selects a single article from the catalog and specifies the desired quantity.
  4. The client submits the form.
* **System Behavior:** 
  * The system retrieves the applicable unit price from the **Prices** table.
  * A new record is inserted into the **Orders** table containing the client details, selected article, quantity, and retrieved price.

---
## 3. Defect  Backlog   (TBD)

| ID | Defect | Description  | Priority |
| :--- | :--- | :--- | :--- |
| **DF-01** | **Product not chosen - system hangs** | The submit button is not blocked if no article is chosen by customer, so customer can submit order with "no produt". System hangs | High |
## 4. Product Backlog   (TBD)

The following features are scoped for upcoming iterations to improve user experience, security, and administrative efficiency:

| ID | Feature / User Story | Description & Acceptance Criteria | Priority |
| :--- | :--- | :--- | :--- |
| **BL-01** | **Display Unit Pricing** | Expose the unit price alongside the article name in the selection interface so clients have visibility into costs before ordering. | High |
| **BL-02** | **Multi-Item Orders** | Update the UI and database logic to allow clients to add multiple distinct articles into a single order submission. | High |
| **BL-03** | **Order Total Calculation** | Display a real-time grand total for the entire order prior to submission. | Medium |
| **BL-04** | **Line-Item Subtotals** | *(Dependent on BL-01 & BL-02)* Calculate and display line-item subtotals (`unit_price × quantity`) for each selected article, alongside the overall order total. | Medium |
| **BL-05** | **Client Authentication** | Implement username and password authentication to replace the open client dropdown, preventing unauthorized or fraudulent ("false flag") orders. | High |
| **BL-06** | **Admin Client Management UI** | Build a dedicated HTML administration form allowing admins to register and onboard new clients without requiring direct SQL database access. | Low | 
| **BL-07** | **Add EDIFAC electronic invoice for order** | Add a button that will generate EDIFACT invoice for the order | Low |
