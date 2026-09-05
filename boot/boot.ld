OUTPUT_FORMAT(binary)
ENTRY(_start)

SECTIONS
{
  . = 0x7c00;
  .text : { *(.text) }

  ASSERT(SIZEOF(.text) <= 510, "boot sector too large")

  . = 0x7c00 + 510;
  .signature : { SHORT(0xaa55) }
}
