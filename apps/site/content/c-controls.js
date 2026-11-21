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
