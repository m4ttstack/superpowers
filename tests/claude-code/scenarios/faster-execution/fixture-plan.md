# Shopping Cart Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A small TypeScript cart library with discounts, checkout and a CLI.

**Architecture:** One module per concern under `src/`, each with a vitest file under `tests/`.

**Tech Stack:** TypeScript 5, vitest.

**Spec:** `docs/specs/cart-design.md`

## Global Constraints

- Money is integer cents; never floats.
- Every public function has a vitest test.

## Review Focus

- A cart with zero items totals 0 cents, not NaN.

---

### Task 1: Config loader

**Files:**
- Create: `src/config.ts`
- Test: `tests/config.test.ts`

**Interfaces:**
- Produces: `loadConfig(env: Record<string, string | undefined>): Config` (consumed by Task 9)

- [ ] **Step 1: Write the failing test** `loadConfig({ CART_CURRENCY: "USD" }).currency === "USD"`
- [ ] **Step 2: Run** `npx vitest run tests/config.test.ts` — Expected: FAIL
- [ ] **Step 3: Implement `loadConfig` in `src/config.ts`**
- [ ] **Step 4: Run** `npx vitest run tests/config.test.ts` — Expected: PASS
- [ ] **Step 5: Commit**

### Task 2: Cart and Money

**Files:**
- Create: `src/cart.ts`
- Test: `tests/cart.test.ts`

**Interfaces:**
- Produces: `type Money = { cents: number }`, `class Cart`, `Cart.addItem(sku: string, price: Money, qty: number): void`

- [ ] **Step 1: Write the failing test** adding two items leaves two lines in the cart
- [ ] **Step 2: Run** `npx vitest run tests/cart.test.ts` — Expected: FAIL
- [ ] **Step 3: Implement `Cart.addItem` in `src/cart.ts`**
- [ ] **Step 4: Run** `npx vitest run tests/cart.test.ts` — Expected: PASS
- [ ] **Step 5: Commit**

### Task 3: Remove items

**Files:**
- Modify: `src/cart.ts`
- Test: `tests/cart.test.ts`

**Interfaces:**
- Consumes: `Cart` from Task 2
- Produces: `Cart.removeItem(sku: string): void`

- [ ] **Step 1: Write the failing test** removing a SKU drops its line; removing an unknown SKU is a no-op
- [ ] **Step 2: Run** `npx vitest run tests/cart.test.ts` — Expected: FAIL
- [ ] **Step 3: Implement `Cart.removeItem` in `src/cart.ts`**
- [ ] **Step 4: Run** `npx vitest run tests/cart.test.ts` — Expected: PASS
- [ ] **Step 5: Commit**

### Task 4: Cart total

**Files:**
- Modify: `src/cart.ts`
- Test: `tests/cart.test.ts`

**Interfaces:**
- Consumes: `Cart`, `Money` from Task 2
- Produces: `Cart.total(): Money`

- [ ] **Step 1: Write the failing test** two lines (250 x 2, 100 x 1) total `{ cents: 600 }`; empty cart totals `{ cents: 0 }`
- [ ] **Step 2: Run** `npx vitest run tests/cart.test.ts` — Expected: FAIL
- [ ] **Step 3: Implement `Cart.total` in `src/cart.ts`**
- [ ] **Step 4: Run** `npx vitest run tests/cart.test.ts` — Expected: PASS
- [ ] **Step 5: Commit**

### Task 5: Discounts

**Files:**
- Create: `src/discounts.ts`
- Test: `tests/discounts.test.ts`

**Interfaces:**
- Consumes: `Money`, `Cart.total()` from Tasks 2 and 4
- Produces: `applyDiscount(total: Money, code: string): Money`

- [ ] **Step 1: Write the failing test** `SAVE10` takes 10% off, rounding down to whole cents
- [ ] **Step 2: Run** `npx vitest run tests/discounts.test.ts` — Expected: FAIL
- [ ] **Step 3: Implement `applyDiscount` in `src/discounts.ts`**
- [ ] **Step 4: Run** `npx vitest run tests/discounts.test.ts` — Expected: PASS
- [ ] **Step 5: Commit**

### Task 6: Checkout orchestration

This task needs design judgment: it decides how cart, discounts and the
payment adapter interact, including partial-failure handling, and touches
the architecture of the whole library. Use the most capable model.

**Files:**
- Create: `src/checkout.ts`
- Test: `tests/checkout.test.ts`

**Interfaces:**
- Consumes: `Cart`, `applyDiscount`
- Produces: `checkout(cart: Cart, code: string | null, pay: PaymentAdapter): Promise<Receipt>`

- [ ] **Step 1: Write the failing tests** a declined payment leaves the cart unchanged; a discount code applies before payment
- [ ] **Step 2: Run** `npx vitest run tests/checkout.test.ts` — Expected: FAIL
- [ ] **Step 3: Implement `checkout` in `src/checkout.ts`**
- [ ] **Step 4: Run** `npx vitest run tests/checkout.test.ts` — Expected: PASS
- [ ] **Step 5: Commit**

### Task 7: Format cents

**Files:**
- Create: `src/format.ts`
- Test: `tests/format.test.ts`

**Interfaces:**
- Produces: `formatCents(m: Money): string`

- [ ] **Step 1: Write the failing test**

```ts
import { expect, test } from "vitest";
import { formatCents } from "../src/format";
test("formats cents as dollars", () => {
  expect(formatCents({ cents: 1234 })).toBe("$12.34");
});
```

- [ ] **Step 2: Run** `npx vitest run tests/format.test.ts` — Expected: FAIL
- [ ] **Step 3: Implement**

```ts
import type { Money } from "./cart";
export function formatCents(m: Money): string {
  return `$${(m.cents / 100).toFixed(2)}`;
}
```

- [ ] **Step 4: Run** `npx vitest run tests/format.test.ts` — Expected: PASS
- [ ] **Step 5: Commit**

### Task 8: Format line items

**Files:**
- Modify: `src/format.ts`
- Test: `tests/format.test.ts`

**Interfaces:**
- Consumes: `formatCents` from Task 7
- Produces: `formatLine(sku: string, qty: number, price: Money): string`

- [ ] **Step 1: Write the failing test**

```ts
test("formats a line", () => {
  expect(formatLine("A1", 2, { cents: 250 })).toBe("A1 x2 $5.00");
});
```

- [ ] **Step 2: Run** `npx vitest run tests/format.test.ts` — Expected: FAIL
- [ ] **Step 3: Implement**

```ts
export function formatLine(sku: string, qty: number, price: Money): string {
  return `${sku} x${qty} ${formatCents({ cents: price.cents * qty })}`;
}
```

- [ ] **Step 4: Run** `npx vitest run tests/format.test.ts` — Expected: PASS
- [ ] **Step 5: Commit**

### Task 9: CLI entry point

**Interfaces:**
- Consumes: `loadConfig` from Task 1

- [ ] **Step 1: Write the failing test** `cart --version` prints the package version
- [ ] **Step 2: Run the CLI test** — Expected: FAIL
- [ ] **Step 3: Implement the CLI**
- [ ] **Step 4: Run the CLI test** — Expected: PASS
- [ ] **Step 5: Commit**
