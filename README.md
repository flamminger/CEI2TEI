# CEI2TEI
This repository documents the proposal to insert diplomatics concepts into the framework of the TEI-P5 (http://www.tei-c.org/Guidelines/P5/), based on the experiences of the Charters Encoding Initiative (http://www.cei.lmu.de).
A product of the FWF-funded research project "Retain Domain Specific Functionalities in a Generic Repository with Humanities Data (FWF ORD 84. PI: Georg Vogeler)."

### Changes and Missing Elements
`<rubrum>` Element in msDesc/diploDesc, for now moved to `<p sameAs="rubrum">`
- Element für dispositives Verb? Anregung von Jaqueline (?)
- `<idno>` element attribute @id moved to @source, @old moved to @prev
- @rend and @rendition attributes?
- currently no `<w>` element. For now, moved to `<span>` with type word
    - @note is missing as well. for now in @note attribute
- in `<body>` entity tags (persName, placeName, ...) are only allowed within `<span>`
    - currently in `<span><entityName>` construction
- in `<body>` there is currently no replace for `<c>` tag, the TEI `<char>` could be considered. For now, like `<w>` move to span with type char
- what happens with the cei @id? Convert all occurrences in the header to @xml:id and everything else to @corresp?
- `<name>` is missing the @target attribute, moved to corresp for now
- `<choice><expan>` is missing @type for now in @ana
- `<placeName>` is missing @reg, @type, @existent
    - @type moved to @role
    - @existent move to @evidence
    - @reg moved to `<choice><reg><orig>`
- `<orgName>` is missing @reg, @type
    - @type moved to @role
    - @reg --> `<choice><reg><orig>`
- in `<body>` the `<seg>` element is missing. For now, moved to `<span>` with @inst seg
    - seg attribute @part moved to @n, @part is availaible @ tei:seg
- in `<body>` the `<c>` element cannot contain `<choice>´ elements, moved to `<span type="char">`
- in `<body>/<figure>` a replacement for `<cei:rights>` (child of `<figure>`) is missing. For now, moved to `<byline>`
- in `<body>/<figure>` a substitute for `<cei:zone>` is missing. For now, moved to `<note>` with `@sameAs="zone"`
- `<figure><graphic>` nesting is not possible. TEI construction --> `<facsimile><graphic>`, Attributes moved to `<graphic>`
    - text content in `<graphic>` is no longer allowed
        - if desired, element content can be moved to `<desc>` element
- `<figure>figDesc>` moved to `<facisimile><graphic><desc>`
- `<authDesc><desc>` has no `<p>` element. For now, moved to `<decoNote><p>`
- `<sigillant>` is missing. For now, moved to `<legalActor type="issuer">`
- attribute `@place` of `<seal>/<legend>` element is missing. For now, replaced with `@rendition`
- `<cei:front><cei:sourceDesc><cei:sourceDescRegest>` replacement is missing. For now, moved to: `<front><listBibl><bibl type="regest">`
    - other option: `<physcDesc><accMat><listBibl><bibl type="regest">`, but not all files have `physcDesc` Elements
    - `<cei:diplomaticAnalysis><cei:listBiblEdition>` and `<cei:listBiblErw>` replacements are missing. For now, moved to `<diploDesc><additional>` with either `n="edition"` or `n="extension"`
- `<cei:language_MOM>` moved to `<profileDesc>/<langUsage>/<language>`
- how are we handling none valid charters, like `AUR_1587_VII_07.cei.xml`?
- `<cei:quoteOriginaldatierung>` moved to `diploDesc <origDate><q>`
- `<cei:back><cei:divNotes>` moved to `<back><div>`
- `<cei:altIdentifier>` in `<cei:msIdentifier>`, for now, moved to `<msIdentifier><repository>`
- `<cei:pTenor>` we won't be able to catch everything. E.g., `UrkBremen/2c1824a6-9910-46cc-9d2c-cc8dc8bd2efe.cei.xml` --> mixed content
- `<cei:witness><cei:archIdentifier>` equivalent is missing. For now, moved to `<witness><idno>`
- `<cei:witness><cei:figure>` construct not possible in the new schema. For now, moved to `<witness><bibl type="graphic"><graphic>`
- `<cei:witness><cei:traditioForm>` equivalent is missing. `CopyStatus` is only possible once in the `<listWit>` element. For now, moved to `<witness><distinct>` with attribute `@type="copyStatus"`
- `<cei:text>` attributes moved to `<profileDesc><settingDesc><setting>`
- Filter or keep optional / empty elements?
- grouped all `persName`, `placeName`, `index` list
    - there is no dedicated list for `<index>` elements. For now, moved to `<list type="index"><item><index


## ToDos
- [ ] automated test of larger file sample
- [ ] update schema