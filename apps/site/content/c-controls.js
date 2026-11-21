import { ALL } from './c-surfaces.js';

export const controls = [
  {
    id: 'sticker-button', name: 'Primary button', group: 'Actions', platforms: ALL,
    summary: 'StickerButton: full width, ink fill, a white 18/800 label and a pink hard shadow. One per screen or sheet, at the bottom.',
    states: [
      { label: 'Rest (press it)', html: '<button class="sp-button full" data-snack="Saved">Save</button>' },
      { label: 'Disabled', html: '<button class="sp-button full" disabled>Save</button>' },
      { label: 'Busy', html: '<button class="sp-button full" aria-busy="true">Saving…</button>' },
    ],
    code: {
      flutter: "StickerButton(label: 'Save', onPressed: save)\nconst StickerButton(label: 'Save', onPressed: null) // disabled\nStickerButton(label: 'Save', busy: true, onPressed: save)",
      compose: 'StickerButton("Save", onClick = ::save)\nStickerButton("Save", onClick = {}, enabled = false)',
      swift: 'StickerButton("Save", action: save)\nStickerButton("Save", action: save).disabled(true)',
      html: '<button class="sp-button">Save</button>\n<button class="sp-button" disabled>Save</button>',
    },
    spec: [['Height', '58'], ['Radius', '20'], ['Fill', 'ink; disabled inkMuted'], ['Outline', '2.5 ink'], ['Shadow', '4/4 pink'], ['Label', '18/800 white'], ['Pressed', 'moves 4/4, shadow disappears']],
    rules: ['Never more than one primary button per view.', 'Long labels scale down to fit rather than overflow.'],
  },
  {
    id: 'text-button', name: 'Text button', group: 'Actions', platforms: ALL,
    summary: 'Secondary actions such as "Cancel", "Skip", "Remove" and "Show more" are plain ink text with no outline, optionally underlined at 2px.',
    states: [
      { label: 'Rest', html: '<button class="sp-text-button">Cancel</button><button class="sp-text-button">Show more</button>' },
      { label: 'Underlined', html: '<button class="sp-text-button sp-text-button--underline">Skip</button>' },
      { label: 'Disabled', html: '<button class="sp-text-button" disabled>Remove</button>' },
    ],
    code: {
      flutter: "PopTextButton(label: 'Cancel', onPressed: close)\nPopTextButton(label: 'Skip', underline: true, onPressed: skip)",
      compose: 'PopTextButton("Cancel", onClick = ::close)\nPopTextButton("Skip", onClick = ::skip, underline = true)',
      swift: 'PopTextButton("Cancel", action: close)\nPopTextButton("Skip", underline: true, action: skip)',
      html: '<button class="sp-text-button">Cancel</button>\n<button class="sp-text-button sp-text-button--underline">Skip</button>',
    },
    spec: [['Text', '15–16 / 700–800 ink'], ['Underline', 'optional, 2 thick'], ['Tap target', 'at least 48 × 48']],
  },
  {
    id: 'icon-button', name: 'PopIconButton', group: 'Actions', platforms: ALL,
    summary: 'A 46 round sticker with one 22 icon, for back, settings and close.',
    states: [
      { label: 'Rest', html: '<button class="sp-icon-button" aria-label="Back"><span class="sp-icon">arrow_back</span></button><button class="sp-icon-button sp-fill-pink" aria-label="Voice"><span class="sp-icon">mic</span></button>' },
      { label: 'Selected', html: '<button class="sp-icon-button sp-fill-yellow" aria-label="Filters on" aria-pressed="true"><span class="sp-icon">tune</span></button>' },
      { label: 'Disabled', html: '<button class="sp-icon-button" aria-label="Close" disabled><span class="sp-icon">close</span></button>' },
    ],
    code: {
      flutter: "PopIconButton(icon: Icons.arrow_back_rounded, label: 'Back', onTap: pop)",
      compose: 'PopIconButton(Icons.Rounded.ArrowBack, label = "Back", onClick = ::pop)',
      swift: 'PopIconButton(systemImage: "chevron.left", label: "Back", action: pop)',
      html: '<button class="sp-icon-button" aria-label="Back">\n  <span class="sp-icon">arrow_back</span>\n</button>',
    },
    spec: [['Size', '46 circle'], ['Outline', '2.5 ink (selected 3)'], ['Shadow', '3/3 ink'], ['Icon', '22 ink']],
    a11y: 'The label is required by the API in every library: icon-only controls must be named.',
  },
  {
    id: 'chip', name: 'PopChip', group: 'Selection', platforms: ALL,
    summary: 'A selectable pill. Selection is shown by fill, a thicker outline, a 2/2 shadow and bolder text, never by colour alone.',
    states: [
      { label: 'Rest', html: '<button class="sp-chip" aria-pressed="false">Travel</button><button class="sp-chip" aria-pressed="false"><span class="sp-icon">flight</span>With icon</button>' },
      { label: 'Selected', html: '<button class="sp-chip" aria-pressed="true">Food</button><button class="sp-chip" aria-pressed="true" style="--sp-chip-fill:var(--sp-color-mint)">Groceries</button>' },
      { label: 'Disabled', html: '<button class="sp-chip" disabled>Bills</button>' },
      { label: 'Removable', html: '<span class="sp-chip sp-chip--removable">Office<button class="sp-chip__remove" aria-label="Remove Office"><span class="sp-icon" style="font-size:16px">close</span></button></span>' },
    ],
    code: {
      flutter: "PopChip(label: 'Food', selected: picked == 'food', onTap: () => pick('food'))\nPopChip(label: 'Office', selected: false, onTap: edit, onRemove: remove)",
      compose: 'PopChip("Food", selected = picked == "food", onClick = { pick("food") })',
      swift: 'PopChip("Food", selected: picked == "food") { pick("food") }',
      html: '<button class="sp-chip" aria-pressed="true">Food</button>\n<button class="sp-chip" aria-pressed="false">Travel</button>',
    },
    spec: [['Min height', '40'], ['Padding', '14 × 6'], ['Radius', '19'], ['Rest', 'white, 2 outline, 14/700'], ['Selected', 'bright fill (yellow default), 2.5 outline, 2/2 shadow, 800'], ['Icons', '16 leading; 16 × to remove']],
  },
  {
    id: 'segmented', name: 'PopSegmented', group: 'Selection', platforms: ALL,
    summary: 'Equal segments with one selected, like "Expense | Income | Transfer".',
    states: [
      { label: 'Rest (tap a segment)', html: '<div class="sp-segmented full"><button aria-pressed="true">Expense</button><button aria-pressed="false">Income</button><button aria-pressed="false">Transfer</button></div>' },
      { label: 'Custom fill', html: '<div class="sp-segmented full" style="--sp-segment-fill:var(--sp-color-mint)"><button aria-pressed="false">Expense</button><button aria-pressed="true">Income</button></div>' },
      { label: 'Disabled', html: '<div class="sp-segmented full" aria-disabled="true"><button aria-pressed="true" disabled>Month</button><button disabled>Year</button></div>' },
    ],
    code: {
      flutter: "PopSegmented<Kind>(\n  values: Kind.values,\n  selected: kind,\n  labelOf: (k) => k.label,\n  onChanged: (k) => setState(() => kind = k),\n)",
      compose: 'PopSegmented(Kind.entries, selected = kind, label = { it.label }, onChange = { kind = it })',
      swift: 'PopSegmented(Kind.allCases, selection: $kind, label: \\.label)',
      html: '<div class="sp-segmented" role="group" aria-label="Type">\n  <button aria-pressed="true">Expense</button>\n  <button aria-pressed="false">Income</button>\n</div>',
    },
    spec: [['Container', 'white, 2.5 outline, radius 18'], ['Segment height', '44'], ['Dividers', '2.5 ink vertical lines'], ['Selected', 'bright fill (pink default), 15/800'], ['Others', 'white, 15/700']],
  },
  {
    id: 'switch', name: 'PopSwitch', group: 'Selection', platforms: ALL,
    summary: 'An on/off switch: white off, mint on; the knob slides (motion.toggle, currently 150 ms).',
    states: [
      { label: 'Off / on (tap)', html: '<button class="sp-switch" role="switch" aria-checked="false" aria-label="Weekly summary"></button><button class="sp-switch" role="switch" aria-checked="true" aria-label="Reminders"></button>' },
      { label: 'Disabled', html: '<button class="sp-switch" role="switch" aria-checked="false" aria-label="Sync" disabled></button>' },
    ],
    code: {
      flutter: "PopSwitch(value: on, label: 'Reminders', onChanged: (v) => setState(() => on = v))",
      compose: 'PopSwitch(checked = on, onCheckedChange = { on = it }, label = "Reminders")',
      swift: 'PopSwitch(isOn: $on, label: "Reminders")',
      html: '<button class="sp-switch" role="switch" aria-checked="true" aria-label="Reminders"></button>',
    },
    spec: [['Track', '52 × 30, radius 15, 2.5 outline'], ['Off / on', 'white / mint'], ['Knob', '21 white circle, 2 outline'], ['Motion', '150 ms']],
    a11y: 'Announced as a switch with its label and on/off state; padded to a 48 tap target.',
  },
  {
    id: 'checkbox', name: 'Checkbox', group: 'Selection', platforms: ALL,
    summary: 'For choosing any number of things, or agreeing to one. A 24 rounded square: white with a 2 ink outline, then mint with a 2.5 outline and an ink tick when checked. A dash means some but not all. Usually as a row, where the whole row toggles.',
    states: [
      { label: 'In a list (tap the rows)', html: '<div class="sp-card sp-list full"><label class="sp-check-row"><input type="checkbox" class="sp-checkbox"  checked><span class="sp-check-row__text"><span class="sp-check-row__label">Include transfers</span><span class="sp-check-row__caption">Moving money between your own accounts</span></span></label><label class="sp-check-row"><input type="checkbox" class="sp-checkbox" ><span class="sp-check-row__text"><span class="sp-check-row__label">Hide small amounts</span></span></label><label class="sp-check-row"><input type="checkbox" class="sp-checkbox"  checked disabled><span class="sp-check-row__text"><span class="sp-check-row__label">Sync</span></span></label></div>' },
      { label: 'Off, on, some, disabled', html: '<input type="checkbox" class="sp-checkbox" aria-label="Off"><input type="checkbox" class="sp-checkbox" aria-label="On" checked><input type="checkbox" class="sp-checkbox" aria-label="Some" data-indeterminate><input type="checkbox" class="sp-checkbox" aria-label="Disabled" disabled><input type="checkbox" class="sp-checkbox" aria-label="Disabled on" checked disabled>' },
    ],
    code: {
      flutter: "PopCheckboxRow(\n  label: 'Include transfers',\n  caption: 'Moving money between your own accounts',\n  value: transfers,\n  onChanged: (v) => setState(() => transfers = v),\n)\n\nPopCheckbox(value: null, tristate: true, semanticLabel: 'All categories', onChanged: selectAll)",
      compose: 'PopCheckboxRow("Include transfers", transfers, { transfers = it }, caption = "Moving money between your own accounts")\n\nPopCheckbox(ToggleableState.Indeterminate, onClick = ::selectAll, label = "All categories")',
      swift: 'PopCheckboxRow("Include transfers", caption: "Moving money between your own accounts", isOn: $transfers)\n\nPopCheckbox("All categories", state: .mixed) { selectAll() }',
      html: '<label class="sp-check-row">\n  <input type="checkbox" class="sp-checkbox" checked>\n  <span class="sp-check-row__text">\n    <span class="sp-check-row__label">Include transfers</span>\n    <span class="sp-check-row__caption">Moving money between your own accounts</span>\n  </span>\n</label>\n\n<!-- "some": set input.indeterminate = true in script -->',
    },
    spec: [['Box', '24, radius 7, padded to 48'], ['Off', 'white, 2 ink outline'], ['On', 'mint, 2.5 outline, ink tick (2.6 stroke)'], ['Some', 'mint, 2.5 outline, ink dash'], ['Disabled', 'paper (divider when on), muted tick'], ['Row', '52 min height, 16 side padding, 12 gap, 16/700 label, 13/600 caption']],
    rules: ['Use a switch for settings that take effect at once; a checkbox for choices confirmed with a button, or picking several things.', 'Labels say what checking it does: "Include transfers", not "Transfers".'],
    a11y: 'Announced as a checkbox with its label and checked, not checked or partly checked. The whole row is the tap target.',
  },
  {
    id: 'radio', name: 'Radio', group: 'Selection', platforms: ALL,
    summary: 'For choosing exactly one of a short list that should all stay visible. A 24 circle: white with a 2 ink outline, then yellow with a 2.5 outline and a 10 ink dot when chosen. Usually as rows in a sticker list.',
    states: [
      { label: 'In a list (tap the rows)', html: '<div class="sp-card sp-list full" role="radiogroup" aria-label="Period"><label class="sp-check-row"><input type="radio" class="sp-radio" name="per"><span class="sp-check-row__text"><span class="sp-check-row__label">Week</span></span></label><label class="sp-check-row"><input type="radio" class="sp-radio" name="per" checked><span class="sp-check-row__text"><span class="sp-check-row__label">Month</span></span></label><label class="sp-check-row"><input type="radio" class="sp-radio" name="per"><span class="sp-check-row__text"><span class="sp-check-row__label">Year</span></span></label></div>' },
      { label: 'Off, on, disabled', html: '<input type="radio" class="sp-radio" name="r-demo" aria-label="Off"><input type="radio" class="sp-radio" name="r-demo" aria-label="On" checked><input type="radio" class="sp-radio" name="r-demo-2" aria-label="Disabled" disabled><input type="radio" class="sp-radio" name="r-demo-3" aria-label="Disabled on" checked disabled>' },
    ],
    code: {
      flutter: "for (final p in ['Week', 'Month', 'Year'])\n  PopRadioRow<String>(label: p, value: p, groupValue: period, onChanged: (v) => setState(() => period = v))",
      compose: 'listOf("Week", "Month", "Year").forEach { p ->\n    PopRadioRow(p, selected = period == p, onClick = { period = p })\n}',
      swift: 'ForEach(["Week", "Month", "Year"], id: \\.self) { p in\n    PopRadioRow(p, value: p, selection: $period)\n}',
      html: '<div class="sp-card sp-list" role="radiogroup" aria-label="Period">\n  <label class="sp-check-row"><input type="radio" class="sp-radio" name="period" checked>\n    <span class="sp-check-row__text"><span class="sp-check-row__label">Month</span></span></label>\n  …\n</div>',
    },
    spec: [['Circle', '24, padded to 48'], ['Off', 'white, 2 ink outline'], ['On', 'yellow, 2.5 outline, 10 ink dot'], ['Disabled', 'paper (divider when on), muted dot'], ['Row', 'as the checkbox row']],
    rules: ['For two to five short options in a compact space, a segmented control is often better; for many options, a select.', 'One option is always chosen; start with a sensible default.'],
    a11y: 'Announced as a radio button, "1 of 3", with its label and whether it is selected. The rows form one group.',
  },
  {
    id: 'text-field', name: 'Text field', group: 'Inputs', platforms: ALL,
    summary: 'White, a 2 ink outline, radius 14, with a borderless input inside. Errors thicken the outline and add an ink message with ⚠, never red alone.',
    states: [
      { label: 'Rest', html: '<label class="sp-field full"><span class="sp-field__label">Note</span><input class="sp-field__input" placeholder="Add a note"></label>' },
      { label: 'Error', html: '<label class="sp-field full"><span class="sp-field__label">Payee</span><input class="sp-field__input" placeholder="Who was it?" aria-invalid="true"><span class="sp-form-error">Add who you paid.</span></label>' },
      { label: 'Disabled', html: '<label class="sp-field full"><span class="sp-field__label">Account</span><input class="sp-field__input" value="HDFC ·· 4821" disabled></label>' },
    ],
    code: {
      flutter: "PopTextField(label: 'Payee', hint: 'Who was it?', controller: payee, errorText: error)",
      compose: 'PopTextField(value = payee, onValueChange = { payee = it }, label = "Payee", hint = "Who was it?", error = error)',
      swift: 'PopTextField("Who was it?", text: $payee, label: "Payee", error: error)',
      html: '<label class="sp-field">\n  <span class="sp-field__label">Payee</span>\n  <input class="sp-field__input" placeholder="Who was it?" aria-invalid="true">\n  <span class="sp-form-error">Add who you paid.</span>\n</label>',
    },
    spec: [['Fill', 'white (disabled paper)'], ['Outline', '2 ink; focus and error 2.5'], ['Radius', '14'], ['Padding', '12 horizontal'], ['Value', '16–17 / 700'], ['Hint', 'inkMuted 16/600'], ['Error', '14/800 ink with ⚠']],
    rules: ['Never tilt inputs.', 'In sheets, form errors sit directly above the primary button.'],
  },
  {
    id: 'select', name: 'Select (dropdown)', group: 'Inputs', platforms: ALL,
    summary: 'Pick one of many: a field with the chosen option and a chevron. On phones it opens a bottom sheet list; on the web a sticker list pops up under the field. The chosen row is yellow with a tick. For two to five short options use a segmented control or chips instead.',
    states: [
      { label: 'Rest (tap it)', html: '<div class="sp-field full"><label class="sp-field__label" for="sel-account">Account</label><select class="sp-select" id="sel-account"><option value="" disabled selected hidden>Choose an account</option><option value="hdfc" data-icon="account_balance" data-caption="Savings ·· 4821">HDFC</option><option value="icici" data-icon="credit_card" data-caption="Credit card ·· 4411">ICICI</option><option value="sbi" data-icon="account_balance">SBI</option><option value="cash" data-icon="payments">Cash</option></select></div>' },
      { label: 'Chosen', html: '<div class="sp-field full"><label class="sp-field__label" for="sel-account-2">Account</label><select class="sp-select" id="sel-account-2"><option value="" disabled hidden>Choose an account</option><option value="hdfc" selected data-icon="account_balance" data-caption="Savings ·· 4821">HDFC</option><option value="icici" data-icon="credit_card" data-caption="Credit card ·· 4411">ICICI</option><option value="sbi" data-icon="account_balance">SBI</option><option value="cash" data-icon="payments">Cash</option></select></div>' },
      { label: 'Error', html: '<div class="sp-field full"><label class="sp-field__label" for="sel-account-3">Account</label><select class="sp-select" id="sel-account-3" aria-invalid="true"><option value="" disabled selected hidden>Choose an account</option><option value="hdfc" data-icon="account_balance" data-caption="Savings ·· 4821">HDFC</option><option value="icici" data-icon="credit_card" data-caption="Credit card ·· 4411">ICICI</option><option value="sbi" data-icon="account_balance">SBI</option><option value="cash" data-icon="payments">Cash</option></select><span class="sp-form-error">Choose where the money came from.</span></div>' },
      { label: 'Disabled', html: '<div class="sp-field full"><label class="sp-field__label" for="sel-account-4">Account</label><select class="sp-select" id="sel-account-4" disabled><option value="" disabled hidden>Choose an account</option><option value="hdfc" selected data-icon="account_balance" data-caption="Savings ·· 4821">HDFC</option><option value="icici" data-icon="credit_card" data-caption="Credit card ·· 4411">ICICI</option><option value="sbi" data-icon="account_balance">SBI</option><option value="cash" data-icon="payments">Cash</option></select></div>' },
    ],
    code: {
      flutter: "PopSelect<String>(\n  label: 'Account',\n  value: account,\n  options: const [\n    PopSelectOption(value: 'hdfc', label: 'HDFC', icon: Icons.account_balance_rounded, caption: 'Savings ·· 4821'),\n    PopSelectOption(value: 'icici', label: 'ICICI', icon: Icons.credit_card_rounded),\n    PopSelectOption(value: 'cash', label: 'Cash', icon: Icons.payments_rounded),\n  ],\n  onChanged: (v) => setState(() => account = v),\n)",
      compose: 'PopSelect(\n    options = listOf(\n        PopSelectOption("hdfc", "HDFC", Icons.Rounded.AccountBalance, caption = "Savings ·· 4821"),\n        PopSelectOption("icici", "ICICI", Icons.Rounded.CreditCard),\n        PopSelectOption("cash", "Cash", Icons.Rounded.Payments),\n    ),\n    value = account,\n    onValueChange = { account = it },\n    label = "Account",\n)',
      swift: '// Once, at the root of the screen: .popOverlayHost()\nPopSelect([\n    PopSelectOption("HDFC", value: "hdfc", systemImage: "building.columns", caption: "Savings ·· 4821"),\n    PopSelectOption("ICICI", value: "icici", systemImage: "creditcard"),\n    PopSelectOption("Cash", value: "cash", systemImage: "banknote"),\n], selection: $account, label: "Account")',
      html: '<div class="sp-field">\n  <label class="sp-field__label" for="account">Account</label>\n  <select class="sp-select" id="account" name="account">\n    <option value="" disabled selected hidden>Choose an account</option>\n    <option value="hdfc" data-icon="account_balance" data-caption="Savings ·· 4821">HDFC</option>\n    <option value="cash" data-icon="payments">Cash</option>\n  </select>\n</div>\n\n<script type="module">\n  import { wirePopSelects } from \'@sticker-pop/web/behaviors.mjs\';\n  wirePopSelects(); // the native select stays in the form, in sync\n</script>',
    },
    spec: [['Field', 'like a text field: white, 2 outline (open, focus, error 2.5), radius 14, 48 min height'], ['Value', '16/700; hint 16/600 inkMuted'], ['Chevron', '22, flips when the web list is open'], ['List', 'sticker list in a sheet (phones) or a menu popover under the field (web), rows 52, the chosen one yellow with a tick'], ['Option', 'optional 22 icon and a 13/600 caption']],
    rules: ['Use it for six or more options, or options with long names; for two to five, use a segmented control or chips.', 'The sheet title is the field label.', 'Never tilt it.'],
    a11y: 'Announced as a button with its label and the chosen value ("Account, HDFC, opens a list"). In the list the chosen option is announced as selected. On the web: arrow keys, Home, End, type-ahead, Enter to pick, Escape to close.',
  },
  {
    id: 'amount-field', name: 'Amount field', group: 'Inputs', platforms: ALL,
    summary: 'The big amount entry: a bright card with a currency prefix at the same 32/800 size. Choose the colour by meaning, for example yellow for money out, mint for money in, pink for withdrawals.',
    states: [
      { label: 'Yellow', html: '<div class="sp-card sp-fill-yellow sp-amount full"><span class="sp-text-section-label">Expense</span><label class="sp-amount__row">₹<input inputmode="decimal" value="1250.50" aria-label="Amount"></label></div>' },
      { label: 'Mint', html: '<div class="sp-card sp-fill-mint sp-amount full"><span class="sp-text-section-label">Income</span><label class="sp-amount__row">₹<input inputmode="decimal" placeholder="0" aria-label="Amount"></label></div>' },
      { label: 'Pink', html: '<div class="sp-card sp-fill-pink sp-amount full"><span class="sp-text-section-label">Taking money out</span><label class="sp-amount__row">₹<input inputmode="decimal" value="20000" aria-label="Amount"></label></div>' },
    ],
    code: {
      compose: "PopAmountField(amount, { amount = it }, fill = PopColors.mint, label = \"Income\", currencySymbol = \"₹\")",
      swift: "PopAmountField(value: $amount, fill: PopColors.mint, label: \"Income\", currencySymbol: \"₹\")",
      flutter: "PopAmountField(controller: amount, color: PopColors.mint, label: 'Income', currencySymbol: '₹')",
      html: '<div class="sp-card sp-fill-yellow sp-amount">\n  <span class="sp-text-section-label">Expense</span>\n  <label class="sp-amount__row">₹<input inputmode="decimal" aria-label="Amount"></label>\n</div>',
    },
    spec: [['Card', 'StickerCard in a bright'], ['Amount', '32/800 tabular, currency prefix at the same size'], ['Input', 'digits and up to 2 decimals']],
  },
  {
    id: 'field-row', name: 'PopFieldRow', group: 'Inputs', platforms: ALL,
    summary: 'One labelled line inside a details card: a 76-wide muted label column, the value on the right, min height 52 and a 2px divider under each row.',
    states: [
      { label: 'Details card', html: '<div class="sp-card full" style="padding:0"><div class="sp-field-row"><span class="sp-field-row__label">Paid to</span><span class="sp-field-row__value">Chai Point</span></div><div class="sp-field-row"><span class="sp-field-row__label">Account</span><span class="sp-field-row__value">HDFC ·· 4821</span><span class="sp-icon">chevron_right</span></div></div>' },
    ],
    code: {
      compose: "PopFieldRow(\"Account\", showChevron = true, onClick = ::pickAccount) {\n    PopText(\"HDFC ·· 4821\", PopTextSpecs.rowTitle)\n}",
      swift: "PopFieldRow(\"Account\", showChevron: true, action: pickAccount) {\n    PopText(\"HDFC ·· 4821\", PopTextSpecs.rowTitle)\n}",
      flutter: "PopFieldRow(label: 'Account', showChevron: true, onTap: pickAccount,\n  child: PopText('HDFC ·· 4821', spec: PopTextSpecs.rowTitle))",
      html: '<div class="sp-field-row">\n  <span class="sp-field-row__label">Paid to</span>\n  <span class="sp-field-row__value">Chai Point</span>\n</div>',
    },
    spec: [['Label column', '76 wide, 14/700 inkMuted'], ['Min height', '52'], ['Divider', '2px'], ['Chevron', 'optional, 22 ink']],
  },
];
