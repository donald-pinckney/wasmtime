initSidebarItems({"enum":[["AttributeValue","The value of an attribute in a `DebuggingInformationEntry`."],["CallFrameInstruction","A parsed call frame instruction."],["CfaRule","The canonical frame address (CFA) recovery rules."],["CieOrFde","Either a `CommonInformationEntry` (CIE) or a `FrameDescriptionEntry` (FDE)."],["ColumnType","The type of column that a row is referring to."],["DieReference","A reference to a DIE, either relative to the current CU or relative to the section."],["Error","An error that occurred when parsing."],["EvaluationResult","The state of an `Evaluation` after evaluating a DWARF expression. The evaluation is either `Complete`, or it requires more data to continue, as described by the variant."],["LineInstruction","A parsed line number program instruction."],["Location","A single location of a piece of the result of a DWARF expression."],["Operation","A single decoded DWARF expression operation."],["Pointer","A decoded pointer."],["RawLocListEntry","A raw entry in .debug_loclists."],["RawRngListEntry","A raw entry in .debug_rnglists"],["RegisterRule","An entry in the abstract CFI table that describes how to find the value of a register."],["Value","The value of an entry on the DWARF stack."],["ValueType","The type of an entry on the DWARF stack."]],"struct":[["Abbreviation","An abbreviation describes the shape of a `DebuggingInformationEntry`'s type: its code, tag type, whether it has children, and its set of attributes."],["Abbreviations","A set of type abbreviations."],["ArangeEntry","A single parsed arange."],["ArangeEntryIter","An iterator over the aranges from a `.debug_aranges` section."],["Attribute","An attribute in a `DebuggingInformationEntry`, consisting of a name and associated value."],["AttributeSpecification","The description of an attribute in an abbreviated type. It is a pair of name and form."],["AttrsIter","An iterator over a particular entry's attributes."],["Augmentation","We support the z-style augmentation [defined by `.eh_frame`][ehframe]."],["BaseAddresses","Optional base addresses for the relative `DW_EH_PE_*` encoded pointers."],["CallFrameInstructionIter","A lazy iterator parsing call frame instructions."],["CfiEntriesIter","An iterator over CIE and FDE entries in a `.debug_frame` or `.eh_frame` section."],["CommonInformationEntry","A Common Information Entry holds information that is shared among many > Frame Description Entries. There is at least one CIE in every non-empty > `.debug_frame` section."],["CompilationUnitHeader","The header of a compilation unit's debugging information."],["CompilationUnitHeadersIter","An iterator over the compilation- and partial-units of a section."],["CompleteLineProgram","A line number program that has previously been run to completion."],["DebugAbbrev","The `DebugAbbrev` struct represents the abbreviations describing `DebuggingInformationEntry`s' attribute names and forms found in the `.debug_abbrev` section."],["DebugAddr","The raw contents of the `.debug_addr` section."],["DebugAranges","The `DebugAranges` struct represents the DWARF address range information found in the `.debug_aranges` section."],["DebugFrame","`DebugFrame` contains the `.debug_frame` section's frame unwinding information required to unwind to and recover registers from older frames on the stack. For example, this is useful for a debugger that wants to print locals in a backtrace."],["DebugInfo","The `DebugInfo` struct represents the DWARF debugging information found in the `.debug_info` section."],["DebugLine","The `DebugLine` struct contains the source location to instruction mapping found in the `.debug_line` section."],["DebugLineStr","The `DebugLineStr` struct represents the DWARF strings found in the `.debug_line_str` section."],["DebugLoc","The raw contents of the `.debug_loc` section."],["DebugLocLists","The `DebugLocLists` struct represents the DWARF data found in the `.debug_loclists` section."],["DebugPubNames","The `DebugPubNames` struct represents the DWARF public names information found in the `.debug_pubnames` section."],["DebugPubTypes","The `DebugPubTypes` struct represents the DWARF public types information found in the `.debug_info` section."],["DebugRanges","The raw contents of the `.debug_ranges` section."],["DebugRngLists","The `DebugRngLists` struct represents the contents of the `.debug_rnglists` section."],["DebugStr","The `DebugStr` struct represents the DWARF strings found in the `.debug_str` section."],["DebugStrOffsets","The raw contents of the `.debug_str_offsets` section."],["DebugTypes","The `DebugTypes` struct represents the DWARF type information found in the `.debug_types` section."],["DebuggingInformationEntry","A Debugging Information Entry (DIE)."],["Dwarf","All of the commonly used DWARF sections, and other common information."],["EhFrame","`EhFrame` contains the frame unwinding information needed during exception handling found in the `.eh_frame` section."],["EhFrameHdr","`EhFrameHdr` contains the information about the `.eh_frame_hdr` section."],["EhHdrTable","The CFI binary search table that is an optional part of the `.eh_frame_hdr` section."],["EndianReader","An easy way to define a custom `Reader` implementation with a reference to a generic buffer of bytes and an associated endianity."],["EndianSlice","A `&[u8]` slice with endianity metadata."],["EntriesCursor","A cursor into the Debugging Information Entries tree for a compilation unit."],["EntriesTree","The state information for a tree view of the Debugging Information Entries."],["EntriesTreeIter","An iterator that allows traversal of the children of an `EntriesTreeNode`."],["EntriesTreeNode","A node in the Debugging Information Entry tree."],["Evaluation","A DWARF expression evaluator."],["Expression","The bytecode for a DWARF expression or location description."],["FileEntry","An entry in the `LineProgramHeader`'s `file_names` set."],["FileEntryFormat","The format of a compononent of an include directory or file name entry."],["FrameDescriptionEntry","A `FrameDescriptionEntry` is a set of CFA instructions for an address range."],["IncompleteLineProgram","A line number program that has not been run to completion."],["LineInstructions","An iterator yielding parsed instructions."],["LineProgramHeader","A header for a line number program in the `.debug_line` section, as defined in section 6.2.4 of the standard."],["LineRow","A row in the line number program's resulting matrix."],["LineRows","Executes a `LineProgram` to iterate over the rows in the matrix of line number information."],["LineSequence","A sequence within a line number program.  A sequence, as defined in section 6.2.5 of the standard, is a linear subset of a line number program within which addresses are monotonically increasing."],["LocListIter","An iterator over a location list."],["LocationListEntry","A location list entry from the `.debug_loc` or `.debug_loclists` sections."],["LocationLists","The DWARF data found in `.debug_loc` and `.debug_loclists` sections."],["ParsedEhFrameHdr","`ParsedEhFrameHdr` contains the parsed information from the `.eh_frame_hdr` section."],["PartialFrameDescriptionEntry","A partially parsed `FrameDescriptionEntry`."],["Piece","The description of a single piece of the result of a DWARF expression."],["PubNamesEntry","A single parsed pubname."],["PubNamesEntryIter","An iterator over the pubnames from a `.debug_pubnames` section."],["PubTypesEntry","A single parsed pubtype."],["PubTypesEntryIter","An iterator over the pubtypes from a `.debug_pubtypes` section."],["Range","An address range from the `.debug_ranges` or `.debug_rnglists` sections."],["RangeIter","An iterator for the address ranges of a `DebuggingInformationEntry`."],["RangeLists","The DWARF data found in `.debug_ranges` and `.debug_rnglists` sections."],["RawLocListIter","A raw iterator over a location list."],["RawRngListIter","A raw iterator over an address range list."],["ReaderOffsetId","An identifier for an offset within a section reader."],["RegisterRuleIter","An unordered iterator for register rules."],["RngListIter","An iterator over an address range list."],["SectionBaseAddresses","Optional base addresses for the relative `DW_EH_PE_*` encoded pointers in a particular section."],["TypeUnitHeader","The header of a type unit's debugging information."],["TypeUnitHeadersIter","An iterator over the type-units of this `.debug_types` section."],["UninitializedUnwindContext","Common context needed when evaluating the call frame unwinding information."],["Unit","All of the commonly used information for a unit in the `.debug_info` or `.debug_types` sections."],["UnitHeader","The common fields for the headers of compilation units and type units."],["UnitOffset","An offset into the current compilation or type unit."],["UnwindContext","An unwinding context."],["UnwindTable","The `UnwindTable` iteratively evaluates a `FrameDescriptionEntry`'s `CallFrameInstruction` program, yielding the each row one at a time."],["UnwindTableRow","A row in the virtual unwind table that describes how to find the values of the registers in the previous frame for a range of PC addresses."]],"trait":[["LineProgram","A `LineProgram` provides access to a `LineProgramHeader` and a way to add files to the files table if necessary. Gimli consumers should never need to use or see this trait."],["Reader","A trait for reading the data from a DWARF section."],["ReaderOffset","A trait for offsets with a DWARF section."],["Section","A convenience trait for loading DWARF sections from object files.  To be used like:"],["UnwindOffset","An offset into an `UnwindSection`."],["UnwindSection","A section holding unwind information: either `.debug_frame` or `.eh_frame`. See `DebugFrame` and `EhFrame` respectively."]],"type":[["CompleteLineNumberProgram","Deprecated. `CompleteLineNumberProgram` has been renamed to `CompleteLineProgram`."],["EndianArcSlice","An atomically reference counted, thread-safe slice of bytes and associated endianity."],["EndianBuf","`EndianBuf` has been renamed to `EndianSlice`. For ease of upgrading across `gimli` versions, we export this type alias."],["EndianRcSlice","A reference counted, non-thread-safe slice of bytes and associated endianity."],["IncompleteLineNumberProgram","Deprecated. `IncompleteLineNumberProgram` has been renamed to `IncompleteLineProgram`."],["LineNumberProgram","Deprecated. `LineNumberProgram` has been renamed to `LineProgram`."],["LineNumberProgramHeader","Deprecated. `LineNumberProgramHeader` has been renamed to `LineProgramHeader`."],["LineNumberRow","Deprecated. `LineNumberRow` has been renamed to `LineRow`."],["LineNumberSequence","Deprecated. `LineNumberSequence` has been renamed to `LineSequence`."],["Opcode","Deprecated. `Opcode` has been renamed to `LineInstruction`."],["OpcodesIter","Deprecated. `OpcodesIter` has been renamed to `LineInstructions`."],["Result","The result of a parse."],["StateMachine","Deprecated. `StateMachine` has been renamed to `LineRows`."]]});