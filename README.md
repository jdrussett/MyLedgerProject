# MyLedger Personal Finance Tracking Project

## Overview

This is a personal passion project that was created by Jake Russett as an exercise in Salesforce Apex and LWC development. The purpose of the application is to serve as a personal budget and expense tracker in order to better understand one's personal finances. It does not at this time integrate with other providers of financial information, and I obviously strongly discourage the input of any real PCI data into any Salesforce environment, be it for a project like this or any other. The goal is simply to log expenses and income, keep tabs on account balances, and verify against your online banking and credit provider accounts to practice that old-as-time art of reconciling your checkbook... digitally.

### Object Model

There are really only four primary objects of concern in the data model for this project:

> - Accounts
> - Income
> - Expenses
> - Transfers

With these four objects we can keep track of our checking, savings, credit card, investment, cash, digital, and any other accounts with the Accounts object, we can keep track of incurred or accrued expenditures with the Expenses object, sources of income with the Income object, and any transfer of value between accounts that do not logically qualify as either an expense or income with the Transfers object, such as paying off a credit card or sending money between your different banking accounts (just because you pay your card off all at once doesn't mean you spent $500 in one day, now does it?)

![ObjectModel.png](/Resources/ObjectModel.png "See the ERD for the object model")

The relationships between accounts, expenses, and income records are managed through master detail relationships, as this allows for total calculations on accounts based on roll-up summary fields from child expense and income records. Once you instantiate your accounts with their beginning balances, it's just a matter of inputting expenses, income records, and any applicable transfers from there to keep your totals updated.

#### Account Relationships

Each account can have a parent account associated with it; this is recommended for credit card accounts that will look up to their parent account used to fund them when it comes time to pay them off.

### [Automation](./force-app/main/default/classes)

The [TransferTriggerController](./force-app/main/default/classes/TransferTriggerController.cls) class controls the function of a transfer record when it is created, updated, or deleted - it adjusts the subtotal fields on the involved accounts which in turn update the overall balance fields to reflect new or updated transfers. If you initiate a payment of a credit card, it will decrease the balance of both the card's credit balance and the corresponding parent account's balance. If you transfer money from checking to savings, it will decrease the amount from checking and increase by the same amount to savings. The trigger controller class is 100% code covered by the test class.

## What's Coming Next?

The next phase of the project will include building out a more custom interface to reduce clicks for the user and streamline common functions within the app; logging expenses, finding recent expenses and income records easily, checking balances visually and numerically, and more. A combination of Lightning Web Components and Visualforce pages will be used to enhance the user experience in both the web app and the mobile app.

Thanks for visiting! Suggestions are welcome.

\- **Jake**
