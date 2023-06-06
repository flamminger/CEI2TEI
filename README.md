# CEI2TEI
This repository documents the proposal to insert diplomatics concepts into the framework of the TEI-P5 (http://www.tei-c.org/Guidelines/P5/), based on the experiences of the Charters Encoding Initiative (http://www.cei.lmu.de).
A product of the FWF-funded research project "Retain Domain Specific Functionalities in a Generic Repository with Humanities Data (FWF ORD 84. PI: Georg Vogeler)."

### Changes and Missing Elements
`<rubrum>` Element in msDesc/diploDesc, for now moved to `<p sameAs="rubrum">`
  - attributes @type, @position, @facs moved to @n, @style, @facs
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
- `<cei:back><cei:divNotes>` moved to `<back><div type="divNotes">`
- `<cei:back><cei:deprecatedNote>` moved to `<back><div type="deprecatedNotes">`
- `<cei:altIdentifier>` in `<cei:msIdentifier>`, for now, moved to `<msIdentifier><repository>`
- `<cei:pTenor>` we won't be able to catch everything. E.g., `UrkBremen/2c1824a6-9910-46cc-9d2c-cc8dc8bd2efe.cei.xml` --> mixed content
- `<cei:witness><cei:archIdentifier>` equivalent is missing. For now, moved to `<witness><idno>`
- `<cei:witness><cei:figure>` construct not possible in the new schema. For now, moved to `<witness><bibl type="graphic"><graphic>`
- `<cei:witness><cei:traditioForm>` equivalent is missing. `CopyStatus` is only possible once in the `<listWit>` element. For now, moved to `<witness><distinct>` with attribute `@type="copyStatus"`
- `<cei:text>` attributes moved to `<profileDesc><settingDesc><setting>`
- Filter or keep optional / empty elements?
- grouped all `persName`, `placeName`, `index` list
    - there is no dedicated list for `<index>` elements. For now, moved to `<list type="index"><item><index
- `<cei:langMOM>` moved to `<language>`, which requires the attribute ident, for now set to "und"
- `cei:@certainty` and `tei:@cert` are not supporting the same content. CEI = free text, TEI four different options
- `cei:@type` remove whitespace when transforming to `tei:@type`
- mixed content elements within text content is an issue. E.g., `<cei:dimensions><cei:height>450</cei:height> x <cei:width>290-300</cei:width> mm</cei:dimensions>`
- `<cei:class>` is used in different ways. Eg, to encode `<cei:class>Urkunde</cei:class>` or `<cei:class>Erzbischof von Messina</cei:class><cei:persName>Rainaldus</cei:persName>`. For now moved to `<textClass><keywords><term>`
- `<cei:a>` move to `<ref>` 
- removed `<cei:index>` elements without text
- `<cei:back><cei:index>` moved to `<back><list><item><term>` attributes @sublemma, @lemma, are missing for now moved to @n and @next
  - @type moved to `<term>`
- `<cei:nota>` equivalent is missing. For now, moved to `<history copyOf="nota"><summary>`
  - see template for moved attributes
- `<cei:corr>` moved to `corr`, attributes @hand and @sic are missing, moved to @rendition, @source
- `<cei:imprint>` in `<cei:bibl>`elements have been moved to `<biblStruct>` content outside of child elements has been removed
- not existing `<cei:i>` element removed, text content preserved in parent element
- `<cei:pict>` has no corresponding element in TEI, moved to `<figure><graphic>`
  - @hand moved to @change for now
- `<cei:sic>` attribute @corr moved to @rendition
- `<cei:notariusDesc>` and `<cei:notariusSub>` have no corresponding element, moved to `<p sameAs="ceiElementName">`
- not existing`<Elongata>` moved to `<p style="elongata">`
- elements for charter form, like dispositio, are missing, for now moved to `<span type="formularName">`
- `<cei:setPhrase>` move to `<distinct>`


## ToDos
- [ ] refactor templates (in progress)
- [ ] automated test of small file sample (in progress)
- [ ] automated test of larger file sample
- [ ] update schema