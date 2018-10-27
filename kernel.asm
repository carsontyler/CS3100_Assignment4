
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 c6 10 80       	mov    $0x8010c670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 7d 34 10 80       	mov    $0x8010347d,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 84 81 10 80       	push   $0x80108184
80100042:	68 80 c6 10 80       	push   $0x8010c680
80100047:	e8 58 4b 00 00       	call   80104ba4 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 b0 db 10 80 a4 	movl   $0x8010dba4,0x8010dbb0
80100056:	db 10 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 b4 db 10 80 a4 	movl   $0x8010dba4,0x8010dbb4
80100060:	db 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 c6 10 80 	movl   $0x8010c6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 b4 db 10 80    	mov    0x8010dbb4,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c a4 db 10 80 	movl   $0x8010dba4,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 b4 db 10 80       	mov    0x8010dbb4,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 b4 db 10 80       	mov    %eax,0x8010dbb4

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 a4 db 10 80       	mov    $0x8010dba4,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 80 c6 10 80       	push   $0x8010c680
801000c1:	e8 00 4b 00 00       	call   80104bc6 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 b4 db 10 80       	mov    0x8010dbb4,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->sector == sector){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 80 c6 10 80       	push   $0x8010c680
8010010c:	e8 1c 4b 00 00       	call   80104c2d <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 c6 10 80       	push   $0x8010c680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 a1 47 00 00       	call   801048cd <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 a4 db 10 80 	cmpl   $0x8010dba4,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 b0 db 10 80       	mov    0x8010dbb0,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 80 c6 10 80       	push   $0x8010c680
80100188:	e8 a0 4a 00 00       	call   80104c2d <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 a4 db 10 80 	cmpl   $0x8010dba4,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 8b 81 10 80       	push   $0x8010818b
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, sector);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 71 26 00 00       	call   80102858 <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 9c 81 10 80       	push   $0x8010819c
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 30 26 00 00       	call   80102858 <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 a3 81 10 80       	push   $0x801081a3
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 c6 10 80       	push   $0x8010c680
80100255:	e8 6c 49 00 00       	call   80104bc6 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 b4 db 10 80    	mov    0x8010dbb4,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c a4 db 10 80 	movl   $0x8010dba4,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 b4 db 10 80       	mov    0x8010dbb4,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 b4 db 10 80       	mov    %eax,0x8010dbb4

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 fa 46 00 00       	call   801049b8 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 c6 10 80       	push   $0x8010c680
801002c9:	e8 5f 49 00 00       	call   80104c2d <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 c3 03 00 00       	call   80100776 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 e0 b5 10 80       	push   $0x8010b5e0
801003e2:	e8 df 47 00 00       	call   80104bc6 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 aa 81 10 80       	push   $0x801081aa
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 55 03 00 00       	call   80100776 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec b3 81 10 80 	movl   $0x801081b3,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 8e 02 00 00       	call   80100776 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 71 02 00 00       	call   80100776 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 62 02 00 00       	call   80100776 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 54 02 00 00       	call   80100776 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 e0 b5 10 80       	push   $0x8010b5e0
8010055b:	e8 cd 46 00 00       	call   80104c2d <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 14 b6 10 80 00 	movl   $0x0,0x8010b614
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 ba 81 10 80       	push   $0x801081ba
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 c9 81 10 80       	push   $0x801081c9
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 b8 46 00 00       	call   80104c7f <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 cb 81 10 80       	push   $0x801081cb
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)
  
  if((pos/80) >= 24){  // Scroll up.
801006b8:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006bf:	7e 4c                	jle    8010070d <cgaputc+0x10c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006c1:	a1 00 90 10 80       	mov    0x80109000,%eax
801006c6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006cc:	a1 00 90 10 80       	mov    0x80109000,%eax
801006d1:	83 ec 04             	sub    $0x4,%esp
801006d4:	68 60 0e 00 00       	push   $0xe60
801006d9:	52                   	push   %edx
801006da:	50                   	push   %eax
801006db:	e8 08 48 00 00       	call   80104ee8 <memmove>
801006e0:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006e3:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006e7:	b8 80 07 00 00       	mov    $0x780,%eax
801006ec:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006ef:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006f2:	a1 00 90 10 80       	mov    0x80109000,%eax
801006f7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fa:	01 c9                	add    %ecx,%ecx
801006fc:	01 c8                	add    %ecx,%eax
801006fe:	83 ec 04             	sub    $0x4,%esp
80100701:	52                   	push   %edx
80100702:	6a 00                	push   $0x0
80100704:	50                   	push   %eax
80100705:	e8 1f 47 00 00       	call   80104e29 <memset>
8010070a:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
8010070d:	83 ec 08             	sub    $0x8,%esp
80100710:	6a 0e                	push   $0xe
80100712:	68 d4 03 00 00       	push   $0x3d4
80100717:	e8 d5 fb ff ff       	call   801002f1 <outb>
8010071c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010071f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100722:	c1 f8 08             	sar    $0x8,%eax
80100725:	0f b6 c0             	movzbl %al,%eax
80100728:	83 ec 08             	sub    $0x8,%esp
8010072b:	50                   	push   %eax
8010072c:	68 d5 03 00 00       	push   $0x3d5
80100731:	e8 bb fb ff ff       	call   801002f1 <outb>
80100736:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100739:	83 ec 08             	sub    $0x8,%esp
8010073c:	6a 0f                	push   $0xf
8010073e:	68 d4 03 00 00       	push   $0x3d4
80100743:	e8 a9 fb ff ff       	call   801002f1 <outb>
80100748:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010074b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010074e:	0f b6 c0             	movzbl %al,%eax
80100751:	83 ec 08             	sub    $0x8,%esp
80100754:	50                   	push   %eax
80100755:	68 d5 03 00 00       	push   $0x3d5
8010075a:	e8 92 fb ff ff       	call   801002f1 <outb>
8010075f:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100762:	a1 00 90 10 80       	mov    0x80109000,%eax
80100767:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010076a:	01 d2                	add    %edx,%edx
8010076c:	01 d0                	add    %edx,%eax
8010076e:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100773:	90                   	nop
80100774:	c9                   	leave  
80100775:	c3                   	ret    

80100776 <consputc>:

void
consputc(int c)
{
80100776:	55                   	push   %ebp
80100777:	89 e5                	mov    %esp,%ebp
80100779:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010077c:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
80100781:	85 c0                	test   %eax,%eax
80100783:	74 07                	je     8010078c <consputc+0x16>
    cli();
80100785:	e8 86 fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
8010078a:	eb fe                	jmp    8010078a <consputc+0x14>
  }

  if(c == BACKSPACE){
8010078c:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100793:	75 29                	jne    801007be <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100795:	83 ec 0c             	sub    $0xc,%esp
80100798:	6a 08                	push   $0x8
8010079a:	e8 66 60 00 00       	call   80106805 <uartputc>
8010079f:	83 c4 10             	add    $0x10,%esp
801007a2:	83 ec 0c             	sub    $0xc,%esp
801007a5:	6a 20                	push   $0x20
801007a7:	e8 59 60 00 00       	call   80106805 <uartputc>
801007ac:	83 c4 10             	add    $0x10,%esp
801007af:	83 ec 0c             	sub    $0xc,%esp
801007b2:	6a 08                	push   $0x8
801007b4:	e8 4c 60 00 00       	call   80106805 <uartputc>
801007b9:	83 c4 10             	add    $0x10,%esp
801007bc:	eb 0e                	jmp    801007cc <consputc+0x56>
  } else
    uartputc(c);
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	ff 75 08             	pushl  0x8(%ebp)
801007c4:	e8 3c 60 00 00       	call   80106805 <uartputc>
801007c9:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007cc:	83 ec 0c             	sub    $0xc,%esp
801007cf:	ff 75 08             	pushl  0x8(%ebp)
801007d2:	e8 2a fe ff ff       	call   80100601 <cgaputc>
801007d7:	83 c4 10             	add    $0x10,%esp
}
801007da:	90                   	nop
801007db:	c9                   	leave  
801007dc:	c3                   	ret    

801007dd <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007dd:	55                   	push   %ebp
801007de:	89 e5                	mov    %esp,%ebp
801007e0:	83 ec 18             	sub    $0x18,%esp
  int c;

  acquire(&input.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 c0 dd 10 80       	push   $0x8010ddc0
801007eb:	e8 d6 43 00 00       	call   80104bc6 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 42 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    switch(c){
801007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007fb:	83 f8 10             	cmp    $0x10,%eax
801007fe:	74 1e                	je     8010081e <consoleintr+0x41>
80100800:	83 f8 10             	cmp    $0x10,%eax
80100803:	7f 0a                	jg     8010080f <consoleintr+0x32>
80100805:	83 f8 08             	cmp    $0x8,%eax
80100808:	74 69                	je     80100873 <consoleintr+0x96>
8010080a:	e9 99 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
8010080f:	83 f8 15             	cmp    $0x15,%eax
80100812:	74 31                	je     80100845 <consoleintr+0x68>
80100814:	83 f8 7f             	cmp    $0x7f,%eax
80100817:	74 5a                	je     80100873 <consoleintr+0x96>
80100819:	e9 8a 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
    case C('P'):  // Process listing.
      procdump();
8010081e:	e8 50 42 00 00       	call   80104a73 <procdump>
      break;
80100823:	e9 12 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100828:	a1 7c de 10 80       	mov    0x8010de7c,%eax
8010082d:	83 e8 01             	sub    $0x1,%eax
80100830:	a3 7c de 10 80       	mov    %eax,0x8010de7c
        consputc(BACKSPACE);
80100835:	83 ec 0c             	sub    $0xc,%esp
80100838:	68 00 01 00 00       	push   $0x100
8010083d:	e8 34 ff ff ff       	call   80100776 <consputc>
80100842:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100845:	8b 15 7c de 10 80    	mov    0x8010de7c,%edx
8010084b:	a1 78 de 10 80       	mov    0x8010de78,%eax
80100850:	39 c2                	cmp    %eax,%edx
80100852:	0f 84 e2 00 00 00    	je     8010093a <consoleintr+0x15d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100858:	a1 7c de 10 80       	mov    0x8010de7c,%eax
8010085d:	83 e8 01             	sub    $0x1,%eax
80100860:	83 e0 7f             	and    $0x7f,%eax
80100863:	0f b6 80 f4 dd 10 80 	movzbl -0x7fef220c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	3c 0a                	cmp    $0xa,%al
8010086c:	75 ba                	jne    80100828 <consoleintr+0x4b>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010086e:	e9 c7 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100873:	8b 15 7c de 10 80    	mov    0x8010de7c,%edx
80100879:	a1 78 de 10 80       	mov    0x8010de78,%eax
8010087e:	39 c2                	cmp    %eax,%edx
80100880:	0f 84 b4 00 00 00    	je     8010093a <consoleintr+0x15d>
        input.e--;
80100886:	a1 7c de 10 80       	mov    0x8010de7c,%eax
8010088b:	83 e8 01             	sub    $0x1,%eax
8010088e:	a3 7c de 10 80       	mov    %eax,0x8010de7c
        consputc(BACKSPACE);
80100893:	83 ec 0c             	sub    $0xc,%esp
80100896:	68 00 01 00 00       	push   $0x100
8010089b:	e8 d6 fe ff ff       	call   80100776 <consputc>
801008a0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008a3:	e9 92 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801008ac:	0f 84 87 00 00 00    	je     80100939 <consoleintr+0x15c>
801008b2:	8b 15 7c de 10 80    	mov    0x8010de7c,%edx
801008b8:	a1 74 de 10 80       	mov    0x8010de74,%eax
801008bd:	29 c2                	sub    %eax,%edx
801008bf:	89 d0                	mov    %edx,%eax
801008c1:	83 f8 7f             	cmp    $0x7f,%eax
801008c4:	77 73                	ja     80100939 <consoleintr+0x15c>
        c = (c == '\r') ? '\n' : c;
801008c6:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
801008ca:	74 05                	je     801008d1 <consoleintr+0xf4>
801008cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008cf:	eb 05                	jmp    801008d6 <consoleintr+0xf9>
801008d1:	b8 0a 00 00 00       	mov    $0xa,%eax
801008d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008d9:	a1 7c de 10 80       	mov    0x8010de7c,%eax
801008de:	8d 50 01             	lea    0x1(%eax),%edx
801008e1:	89 15 7c de 10 80    	mov    %edx,0x8010de7c
801008e7:	83 e0 7f             	and    $0x7f,%eax
801008ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008ed:	88 90 f4 dd 10 80    	mov    %dl,-0x7fef220c(%eax)
        consputc(c);
801008f3:	83 ec 0c             	sub    $0xc,%esp
801008f6:	ff 75 f4             	pushl  -0xc(%ebp)
801008f9:	e8 78 fe ff ff       	call   80100776 <consputc>
801008fe:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100901:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
80100905:	74 18                	je     8010091f <consoleintr+0x142>
80100907:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
8010090b:	74 12                	je     8010091f <consoleintr+0x142>
8010090d:	a1 7c de 10 80       	mov    0x8010de7c,%eax
80100912:	8b 15 74 de 10 80    	mov    0x8010de74,%edx
80100918:	83 ea 80             	sub    $0xffffff80,%edx
8010091b:	39 d0                	cmp    %edx,%eax
8010091d:	75 1a                	jne    80100939 <consoleintr+0x15c>
          input.w = input.e;
8010091f:	a1 7c de 10 80       	mov    0x8010de7c,%eax
80100924:	a3 78 de 10 80       	mov    %eax,0x8010de78
          wakeup(&input.r);
80100929:	83 ec 0c             	sub    $0xc,%esp
8010092c:	68 74 de 10 80       	push   $0x8010de74
80100931:	e8 82 40 00 00       	call   801049b8 <wakeup>
80100936:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100939:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
8010093a:	8b 45 08             	mov    0x8(%ebp),%eax
8010093d:	ff d0                	call   *%eax
8010093f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100942:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100946:	0f 89 ac fe ff ff    	jns    801007f8 <consoleintr+0x1b>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010094c:	83 ec 0c             	sub    $0xc,%esp
8010094f:	68 c0 dd 10 80       	push   $0x8010ddc0
80100954:	e8 d4 42 00 00       	call   80104c2d <release>
80100959:	83 c4 10             	add    $0x10,%esp
}
8010095c:	90                   	nop
8010095d:	c9                   	leave  
8010095e:	c3                   	ret    

8010095f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010095f:	55                   	push   %ebp
80100960:	89 e5                	mov    %esp,%ebp
80100962:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100965:	83 ec 0c             	sub    $0xc,%esp
80100968:	ff 75 08             	pushl  0x8(%ebp)
8010096b:	e8 df 10 00 00       	call   80101a4f <iunlock>
80100970:	83 c4 10             	add    $0x10,%esp
  target = n;
80100973:	8b 45 10             	mov    0x10(%ebp),%eax
80100976:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 c0 dd 10 80       	push   $0x8010ddc0
80100981:	e8 40 42 00 00       	call   80104bc6 <acquire>
80100986:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100989:	e9 ac 00 00 00       	jmp    80100a3a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
8010098e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100994:	8b 40 24             	mov    0x24(%eax),%eax
80100997:	85 c0                	test   %eax,%eax
80100999:	74 28                	je     801009c3 <consoleread+0x64>
        release(&input.lock);
8010099b:	83 ec 0c             	sub    $0xc,%esp
8010099e:	68 c0 dd 10 80       	push   $0x8010ddc0
801009a3:	e8 85 42 00 00       	call   80104c2d <release>
801009a8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009ab:	83 ec 0c             	sub    $0xc,%esp
801009ae:	ff 75 08             	pushl  0x8(%ebp)
801009b1:	e8 41 0f 00 00       	call   801018f7 <ilock>
801009b6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009be:	e9 ab 00 00 00       	jmp    80100a6e <consoleread+0x10f>
      }
      sleep(&input.r, &input.lock);
801009c3:	83 ec 08             	sub    $0x8,%esp
801009c6:	68 c0 dd 10 80       	push   $0x8010ddc0
801009cb:	68 74 de 10 80       	push   $0x8010de74
801009d0:	e8 f8 3e 00 00       	call   801048cd <sleep>
801009d5:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
801009d8:	8b 15 74 de 10 80    	mov    0x8010de74,%edx
801009de:	a1 78 de 10 80       	mov    0x8010de78,%eax
801009e3:	39 c2                	cmp    %eax,%edx
801009e5:	74 a7                	je     8010098e <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009e7:	a1 74 de 10 80       	mov    0x8010de74,%eax
801009ec:	8d 50 01             	lea    0x1(%eax),%edx
801009ef:	89 15 74 de 10 80    	mov    %edx,0x8010de74
801009f5:	83 e0 7f             	and    $0x7f,%eax
801009f8:	0f b6 80 f4 dd 10 80 	movzbl -0x7fef220c(%eax),%eax
801009ff:	0f be c0             	movsbl %al,%eax
80100a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a05:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a09:	75 17                	jne    80100a22 <consoleread+0xc3>
      if(n < target){
80100a0b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a0e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a11:	73 2f                	jae    80100a42 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a13:	a1 74 de 10 80       	mov    0x8010de74,%eax
80100a18:	83 e8 01             	sub    $0x1,%eax
80100a1b:	a3 74 de 10 80       	mov    %eax,0x8010de74
      }
      break;
80100a20:	eb 20                	jmp    80100a42 <consoleread+0xe3>
    }
    *dst++ = c;
80100a22:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a25:	8d 50 01             	lea    0x1(%eax),%edx
80100a28:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a2e:	88 10                	mov    %dl,(%eax)
    --n;
80100a30:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a34:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a38:	74 0b                	je     80100a45 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100a3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a3e:	7f 98                	jg     801009d8 <consoleread+0x79>
80100a40:	eb 04                	jmp    80100a46 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a42:	90                   	nop
80100a43:	eb 01                	jmp    80100a46 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a45:	90                   	nop
  }
  release(&input.lock);
80100a46:	83 ec 0c             	sub    $0xc,%esp
80100a49:	68 c0 dd 10 80       	push   $0x8010ddc0
80100a4e:	e8 da 41 00 00       	call   80104c2d <release>
80100a53:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a56:	83 ec 0c             	sub    $0xc,%esp
80100a59:	ff 75 08             	pushl  0x8(%ebp)
80100a5c:	e8 96 0e 00 00       	call   801018f7 <ilock>
80100a61:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a64:	8b 45 10             	mov    0x10(%ebp),%eax
80100a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a6a:	29 c2                	sub    %eax,%edx
80100a6c:	89 d0                	mov    %edx,%eax
}
80100a6e:	c9                   	leave  
80100a6f:	c3                   	ret    

80100a70 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a70:	55                   	push   %ebp
80100a71:	89 e5                	mov    %esp,%ebp
80100a73:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	ff 75 08             	pushl  0x8(%ebp)
80100a7c:	e8 ce 0f 00 00       	call   80101a4f <iunlock>
80100a81:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a84:	83 ec 0c             	sub    $0xc,%esp
80100a87:	68 e0 b5 10 80       	push   $0x8010b5e0
80100a8c:	e8 35 41 00 00       	call   80104bc6 <acquire>
80100a91:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100a94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a9b:	eb 21                	jmp    80100abe <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100a9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100aa3:	01 d0                	add    %edx,%eax
80100aa5:	0f b6 00             	movzbl (%eax),%eax
80100aa8:	0f be c0             	movsbl %al,%eax
80100aab:	0f b6 c0             	movzbl %al,%eax
80100aae:	83 ec 0c             	sub    $0xc,%esp
80100ab1:	50                   	push   %eax
80100ab2:	e8 bf fc ff ff       	call   80100776 <consputc>
80100ab7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ac1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ac4:	7c d7                	jl     80100a9d <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100ac6:	83 ec 0c             	sub    $0xc,%esp
80100ac9:	68 e0 b5 10 80       	push   $0x8010b5e0
80100ace:	e8 5a 41 00 00       	call   80104c2d <release>
80100ad3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ad6:	83 ec 0c             	sub    $0xc,%esp
80100ad9:	ff 75 08             	pushl  0x8(%ebp)
80100adc:	e8 16 0e 00 00       	call   801018f7 <ilock>
80100ae1:	83 c4 10             	add    $0x10,%esp

  return n;
80100ae4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ae7:	c9                   	leave  
80100ae8:	c3                   	ret    

80100ae9 <consoleinit>:

void
consoleinit(void)
{
80100ae9:	55                   	push   %ebp
80100aea:	89 e5                	mov    %esp,%ebp
80100aec:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100aef:	83 ec 08             	sub    $0x8,%esp
80100af2:	68 cf 81 10 80       	push   $0x801081cf
80100af7:	68 e0 b5 10 80       	push   $0x8010b5e0
80100afc:	e8 a3 40 00 00       	call   80104ba4 <initlock>
80100b01:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100b04:	83 ec 08             	sub    $0x8,%esp
80100b07:	68 d7 81 10 80       	push   $0x801081d7
80100b0c:	68 c0 dd 10 80       	push   $0x8010ddc0
80100b11:	e8 8e 40 00 00       	call   80104ba4 <initlock>
80100b16:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b19:	c7 05 2c e8 10 80 70 	movl   $0x80100a70,0x8010e82c
80100b20:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b23:	c7 05 28 e8 10 80 5f 	movl   $0x8010095f,0x8010e828
80100b2a:	09 10 80 
  cons.locking = 1;
80100b2d:	c7 05 14 b6 10 80 01 	movl   $0x1,0x8010b614
80100b34:	00 00 00 

  picenable(IRQ_KBD);
80100b37:	83 ec 0c             	sub    $0xc,%esp
80100b3a:	6a 01                	push   $0x1
80100b3c:	e8 f0 2f 00 00       	call   80103b31 <picenable>
80100b41:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b44:	83 ec 08             	sub    $0x8,%esp
80100b47:	6a 00                	push   $0x0
80100b49:	6a 01                	push   $0x1
80100b4b:	e8 d5 1e 00 00       	call   80102a25 <ioapicenable>
80100b50:	83 c4 10             	add    $0x10,%esp
}
80100b53:	90                   	nop
80100b54:	c9                   	leave  
80100b55:	c3                   	ret    

80100b56 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b56:	55                   	push   %ebp
80100b57:	89 e5                	mov    %esp,%ebp
80100b59:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100b5f:	83 ec 0c             	sub    $0xc,%esp
80100b62:	ff 75 08             	pushl  0x8(%ebp)
80100b65:	e8 45 19 00 00       	call   801024af <namei>
80100b6a:	83 c4 10             	add    $0x10,%esp
80100b6d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b70:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b74:	75 0a                	jne    80100b80 <exec+0x2a>
    return -1;
80100b76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b7b:	e9 c4 03 00 00       	jmp    80100f44 <exec+0x3ee>
  ilock(ip);
80100b80:	83 ec 0c             	sub    $0xc,%esp
80100b83:	ff 75 d8             	pushl  -0x28(%ebp)
80100b86:	e8 6c 0d 00 00       	call   801018f7 <ilock>
80100b8b:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100b8e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b95:	6a 34                	push   $0x34
80100b97:	6a 00                	push   $0x0
80100b99:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b9f:	50                   	push   %eax
80100ba0:	ff 75 d8             	pushl  -0x28(%ebp)
80100ba3:	e8 b7 12 00 00       	call   80101e5f <readi>
80100ba8:	83 c4 10             	add    $0x10,%esp
80100bab:	83 f8 33             	cmp    $0x33,%eax
80100bae:	0f 86 44 03 00 00    	jbe    80100ef8 <exec+0x3a2>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bb4:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bba:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100bbf:	0f 85 36 03 00 00    	jne    80100efb <exec+0x3a5>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bc5:	e8 95 6d 00 00       	call   8010795f <setupkvm>
80100bca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bcd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bd1:	0f 84 27 03 00 00    	je     80100efe <exec+0x3a8>
    goto bad;

  // Load program into memory.
  sz = 0;
80100bd7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100bde:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100be5:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100beb:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bee:	e9 ab 00 00 00       	jmp    80100c9e <exec+0x148>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bf6:	6a 20                	push   $0x20
80100bf8:	50                   	push   %eax
80100bf9:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bff:	50                   	push   %eax
80100c00:	ff 75 d8             	pushl  -0x28(%ebp)
80100c03:	e8 57 12 00 00       	call   80101e5f <readi>
80100c08:	83 c4 10             	add    $0x10,%esp
80100c0b:	83 f8 20             	cmp    $0x20,%eax
80100c0e:	0f 85 ed 02 00 00    	jne    80100f01 <exec+0x3ab>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c14:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c1a:	83 f8 01             	cmp    $0x1,%eax
80100c1d:	75 71                	jne    80100c90 <exec+0x13a>
      continue;
    if(ph.memsz < ph.filesz)
80100c1f:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c25:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c2b:	39 c2                	cmp    %eax,%edx
80100c2d:	0f 82 d1 02 00 00    	jb     80100f04 <exec+0x3ae>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c33:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c39:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c3f:	01 d0                	add    %edx,%eax
80100c41:	83 ec 04             	sub    $0x4,%esp
80100c44:	50                   	push   %eax
80100c45:	ff 75 e0             	pushl  -0x20(%ebp)
80100c48:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c4b:	e8 b6 70 00 00       	call   80107d06 <allocuvm>
80100c50:	83 c4 10             	add    $0x10,%esp
80100c53:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c56:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c5a:	0f 84 a7 02 00 00    	je     80100f07 <exec+0x3b1>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c60:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c66:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c6c:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c72:	83 ec 0c             	sub    $0xc,%esp
80100c75:	52                   	push   %edx
80100c76:	50                   	push   %eax
80100c77:	ff 75 d8             	pushl  -0x28(%ebp)
80100c7a:	51                   	push   %ecx
80100c7b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c7e:	e8 ac 6f 00 00       	call   80107c2f <loaduvm>
80100c83:	83 c4 20             	add    $0x20,%esp
80100c86:	85 c0                	test   %eax,%eax
80100c88:	0f 88 7c 02 00 00    	js     80100f0a <exec+0x3b4>
80100c8e:	eb 01                	jmp    80100c91 <exec+0x13b>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c90:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c91:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c95:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c98:	83 c0 20             	add    $0x20,%eax
80100c9b:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c9e:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100ca5:	0f b7 c0             	movzwl %ax,%eax
80100ca8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cab:	0f 8f 42 ff ff ff    	jg     80100bf3 <exec+0x9d>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cb1:	83 ec 0c             	sub    $0xc,%esp
80100cb4:	ff 75 d8             	pushl  -0x28(%ebp)
80100cb7:	e8 f5 0e 00 00       	call   80101bb1 <iunlockput>
80100cbc:	83 c4 10             	add    $0x10,%esp
  ip = 0;
80100cbf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cc9:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd9:	05 00 20 00 00       	add    $0x2000,%eax
80100cde:	83 ec 04             	sub    $0x4,%esp
80100ce1:	50                   	push   %eax
80100ce2:	ff 75 e0             	pushl  -0x20(%ebp)
80100ce5:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ce8:	e8 19 70 00 00       	call   80107d06 <allocuvm>
80100ced:	83 c4 10             	add    $0x10,%esp
80100cf0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cf3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cf7:	0f 84 10 02 00 00    	je     80100f0d <exec+0x3b7>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d00:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d05:	83 ec 08             	sub    $0x8,%esp
80100d08:	50                   	push   %eax
80100d09:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d0c:	e8 1b 72 00 00       	call   80107f2c <clearpteu>
80100d11:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d14:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d17:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d1a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d21:	e9 96 00 00 00       	jmp    80100dbc <exec+0x266>
    if(argc >= MAXARG)
80100d26:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d2a:	0f 87 e0 01 00 00    	ja     80100f10 <exec+0x3ba>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d33:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d3d:	01 d0                	add    %edx,%eax
80100d3f:	8b 00                	mov    (%eax),%eax
80100d41:	83 ec 0c             	sub    $0xc,%esp
80100d44:	50                   	push   %eax
80100d45:	e8 2c 43 00 00       	call   80105076 <strlen>
80100d4a:	83 c4 10             	add    $0x10,%esp
80100d4d:	89 c2                	mov    %eax,%edx
80100d4f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d52:	29 d0                	sub    %edx,%eax
80100d54:	83 e8 01             	sub    $0x1,%eax
80100d57:	83 e0 fc             	and    $0xfffffffc,%eax
80100d5a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d60:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d67:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d6a:	01 d0                	add    %edx,%eax
80100d6c:	8b 00                	mov    (%eax),%eax
80100d6e:	83 ec 0c             	sub    $0xc,%esp
80100d71:	50                   	push   %eax
80100d72:	e8 ff 42 00 00       	call   80105076 <strlen>
80100d77:	83 c4 10             	add    $0x10,%esp
80100d7a:	83 c0 01             	add    $0x1,%eax
80100d7d:	89 c1                	mov    %eax,%ecx
80100d7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d82:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d89:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d8c:	01 d0                	add    %edx,%eax
80100d8e:	8b 00                	mov    (%eax),%eax
80100d90:	51                   	push   %ecx
80100d91:	50                   	push   %eax
80100d92:	ff 75 dc             	pushl  -0x24(%ebp)
80100d95:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d98:	e8 46 73 00 00       	call   801080e3 <copyout>
80100d9d:	83 c4 10             	add    $0x10,%esp
80100da0:	85 c0                	test   %eax,%eax
80100da2:	0f 88 6b 01 00 00    	js     80100f13 <exec+0x3bd>
      goto bad;
    ustack[3+argc] = sp;
80100da8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dab:	8d 50 03             	lea    0x3(%eax),%edx
80100dae:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100db1:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100db8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100dbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dbf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc9:	01 d0                	add    %edx,%eax
80100dcb:	8b 00                	mov    (%eax),%eax
80100dcd:	85 c0                	test   %eax,%eax
80100dcf:	0f 85 51 ff ff ff    	jne    80100d26 <exec+0x1d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd8:	83 c0 03             	add    $0x3,%eax
80100ddb:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100de2:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100de6:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100ded:	ff ff ff 
  ustack[1] = argc;
80100df0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df3:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100df9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dfc:	83 c0 01             	add    $0x1,%eax
80100dff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e06:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e09:	29 d0                	sub    %edx,%eax
80100e0b:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e14:	83 c0 04             	add    $0x4,%eax
80100e17:	c1 e0 02             	shl    $0x2,%eax
80100e1a:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e20:	83 c0 04             	add    $0x4,%eax
80100e23:	c1 e0 02             	shl    $0x2,%eax
80100e26:	50                   	push   %eax
80100e27:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e2d:	50                   	push   %eax
80100e2e:	ff 75 dc             	pushl  -0x24(%ebp)
80100e31:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e34:	e8 aa 72 00 00       	call   801080e3 <copyout>
80100e39:	83 c4 10             	add    $0x10,%esp
80100e3c:	85 c0                	test   %eax,%eax
80100e3e:	0f 88 d2 00 00 00    	js     80100f16 <exec+0x3c0>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e44:	8b 45 08             	mov    0x8(%ebp),%eax
80100e47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e50:	eb 17                	jmp    80100e69 <exec+0x313>
    if(*s == '/')
80100e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e55:	0f b6 00             	movzbl (%eax),%eax
80100e58:	3c 2f                	cmp    $0x2f,%al
80100e5a:	75 09                	jne    80100e65 <exec+0x30f>
      last = s+1;
80100e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e5f:	83 c0 01             	add    $0x1,%eax
80100e62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6c:	0f b6 00             	movzbl (%eax),%eax
80100e6f:	84 c0                	test   %al,%al
80100e71:	75 df                	jne    80100e52 <exec+0x2fc>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e79:	83 c0 6c             	add    $0x6c,%eax
80100e7c:	83 ec 04             	sub    $0x4,%esp
80100e7f:	6a 10                	push   $0x10
80100e81:	ff 75 f0             	pushl  -0x10(%ebp)
80100e84:	50                   	push   %eax
80100e85:	e8 a2 41 00 00       	call   8010502c <safestrcpy>
80100e8a:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e8d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e93:	8b 40 04             	mov    0x4(%eax),%eax
80100e96:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e99:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e9f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ea2:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ea5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eab:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100eae:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb6:	8b 40 18             	mov    0x18(%eax),%eax
80100eb9:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ebf:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ec2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec8:	8b 40 18             	mov    0x18(%eax),%eax
80100ecb:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ece:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ed1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed7:	83 ec 0c             	sub    $0xc,%esp
80100eda:	50                   	push   %eax
80100edb:	e8 66 6b 00 00       	call   80107a46 <switchuvm>
80100ee0:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100ee3:	83 ec 0c             	sub    $0xc,%esp
80100ee6:	ff 75 d0             	pushl  -0x30(%ebp)
80100ee9:	e8 9e 6f 00 00       	call   80107e8c <freevm>
80100eee:	83 c4 10             	add    $0x10,%esp
  return 0;
80100ef1:	b8 00 00 00 00       	mov    $0x0,%eax
80100ef6:	eb 4c                	jmp    80100f44 <exec+0x3ee>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100ef8:	90                   	nop
80100ef9:	eb 1c                	jmp    80100f17 <exec+0x3c1>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100efb:	90                   	nop
80100efc:	eb 19                	jmp    80100f17 <exec+0x3c1>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100efe:	90                   	nop
80100eff:	eb 16                	jmp    80100f17 <exec+0x3c1>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f01:	90                   	nop
80100f02:	eb 13                	jmp    80100f17 <exec+0x3c1>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f04:	90                   	nop
80100f05:	eb 10                	jmp    80100f17 <exec+0x3c1>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f07:	90                   	nop
80100f08:	eb 0d                	jmp    80100f17 <exec+0x3c1>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f0a:	90                   	nop
80100f0b:	eb 0a                	jmp    80100f17 <exec+0x3c1>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100f0d:	90                   	nop
80100f0e:	eb 07                	jmp    80100f17 <exec+0x3c1>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f10:	90                   	nop
80100f11:	eb 04                	jmp    80100f17 <exec+0x3c1>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f13:	90                   	nop
80100f14:	eb 01                	jmp    80100f17 <exec+0x3c1>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f16:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f17:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f1b:	74 0e                	je     80100f2b <exec+0x3d5>
    freevm(pgdir);
80100f1d:	83 ec 0c             	sub    $0xc,%esp
80100f20:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f23:	e8 64 6f 00 00       	call   80107e8c <freevm>
80100f28:	83 c4 10             	add    $0x10,%esp
  if(ip)
80100f2b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f2f:	74 0e                	je     80100f3f <exec+0x3e9>
    iunlockput(ip);
80100f31:	83 ec 0c             	sub    $0xc,%esp
80100f34:	ff 75 d8             	pushl  -0x28(%ebp)
80100f37:	e8 75 0c 00 00       	call   80101bb1 <iunlockput>
80100f3c:	83 c4 10             	add    $0x10,%esp
  return -1;
80100f3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f44:	c9                   	leave  
80100f45:	c3                   	ret    

80100f46 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f46:	55                   	push   %ebp
80100f47:	89 e5                	mov    %esp,%ebp
80100f49:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f4c:	83 ec 08             	sub    $0x8,%esp
80100f4f:	68 dd 81 10 80       	push   $0x801081dd
80100f54:	68 80 de 10 80       	push   $0x8010de80
80100f59:	e8 46 3c 00 00       	call   80104ba4 <initlock>
80100f5e:	83 c4 10             	add    $0x10,%esp
}
80100f61:	90                   	nop
80100f62:	c9                   	leave  
80100f63:	c3                   	ret    

80100f64 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f64:	55                   	push   %ebp
80100f65:	89 e5                	mov    %esp,%ebp
80100f67:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f6a:	83 ec 0c             	sub    $0xc,%esp
80100f6d:	68 80 de 10 80       	push   $0x8010de80
80100f72:	e8 4f 3c 00 00       	call   80104bc6 <acquire>
80100f77:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f7a:	c7 45 f4 b4 de 10 80 	movl   $0x8010deb4,-0xc(%ebp)
80100f81:	eb 2d                	jmp    80100fb0 <filealloc+0x4c>
    if(f->ref == 0){
80100f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f86:	8b 40 04             	mov    0x4(%eax),%eax
80100f89:	85 c0                	test   %eax,%eax
80100f8b:	75 1f                	jne    80100fac <filealloc+0x48>
      f->ref = 1;
80100f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f90:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f97:	83 ec 0c             	sub    $0xc,%esp
80100f9a:	68 80 de 10 80       	push   $0x8010de80
80100f9f:	e8 89 3c 00 00       	call   80104c2d <release>
80100fa4:	83 c4 10             	add    $0x10,%esp
      return f;
80100fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100faa:	eb 23                	jmp    80100fcf <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fac:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fb0:	b8 14 e8 10 80       	mov    $0x8010e814,%eax
80100fb5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100fb8:	72 c9                	jb     80100f83 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fba:	83 ec 0c             	sub    $0xc,%esp
80100fbd:	68 80 de 10 80       	push   $0x8010de80
80100fc2:	e8 66 3c 00 00       	call   80104c2d <release>
80100fc7:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fca:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fcf:	c9                   	leave  
80100fd0:	c3                   	ret    

80100fd1 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fd1:	55                   	push   %ebp
80100fd2:	89 e5                	mov    %esp,%ebp
80100fd4:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80100fd7:	83 ec 0c             	sub    $0xc,%esp
80100fda:	68 80 de 10 80       	push   $0x8010de80
80100fdf:	e8 e2 3b 00 00       	call   80104bc6 <acquire>
80100fe4:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80100fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80100fea:	8b 40 04             	mov    0x4(%eax),%eax
80100fed:	85 c0                	test   %eax,%eax
80100fef:	7f 0d                	jg     80100ffe <filedup+0x2d>
    panic("filedup");
80100ff1:	83 ec 0c             	sub    $0xc,%esp
80100ff4:	68 e4 81 10 80       	push   $0x801081e4
80100ff9:	e8 68 f5 ff ff       	call   80100566 <panic>
  f->ref++;
80100ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80101001:	8b 40 04             	mov    0x4(%eax),%eax
80101004:	8d 50 01             	lea    0x1(%eax),%edx
80101007:	8b 45 08             	mov    0x8(%ebp),%eax
8010100a:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010100d:	83 ec 0c             	sub    $0xc,%esp
80101010:	68 80 de 10 80       	push   $0x8010de80
80101015:	e8 13 3c 00 00       	call   80104c2d <release>
8010101a:	83 c4 10             	add    $0x10,%esp
  return f;
8010101d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101020:	c9                   	leave  
80101021:	c3                   	ret    

80101022 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101022:	55                   	push   %ebp
80101023:	89 e5                	mov    %esp,%ebp
80101025:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101028:	83 ec 0c             	sub    $0xc,%esp
8010102b:	68 80 de 10 80       	push   $0x8010de80
80101030:	e8 91 3b 00 00       	call   80104bc6 <acquire>
80101035:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101038:	8b 45 08             	mov    0x8(%ebp),%eax
8010103b:	8b 40 04             	mov    0x4(%eax),%eax
8010103e:	85 c0                	test   %eax,%eax
80101040:	7f 0d                	jg     8010104f <fileclose+0x2d>
    panic("fileclose");
80101042:	83 ec 0c             	sub    $0xc,%esp
80101045:	68 ec 81 10 80       	push   $0x801081ec
8010104a:	e8 17 f5 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
8010104f:	8b 45 08             	mov    0x8(%ebp),%eax
80101052:	8b 40 04             	mov    0x4(%eax),%eax
80101055:	8d 50 ff             	lea    -0x1(%eax),%edx
80101058:	8b 45 08             	mov    0x8(%ebp),%eax
8010105b:	89 50 04             	mov    %edx,0x4(%eax)
8010105e:	8b 45 08             	mov    0x8(%ebp),%eax
80101061:	8b 40 04             	mov    0x4(%eax),%eax
80101064:	85 c0                	test   %eax,%eax
80101066:	7e 15                	jle    8010107d <fileclose+0x5b>
    release(&ftable.lock);
80101068:	83 ec 0c             	sub    $0xc,%esp
8010106b:	68 80 de 10 80       	push   $0x8010de80
80101070:	e8 b8 3b 00 00       	call   80104c2d <release>
80101075:	83 c4 10             	add    $0x10,%esp
80101078:	e9 8b 00 00 00       	jmp    80101108 <fileclose+0xe6>
    return;
  }
  ff = *f;
8010107d:	8b 45 08             	mov    0x8(%ebp),%eax
80101080:	8b 10                	mov    (%eax),%edx
80101082:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101085:	8b 50 04             	mov    0x4(%eax),%edx
80101088:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010108b:	8b 50 08             	mov    0x8(%eax),%edx
8010108e:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101091:	8b 50 0c             	mov    0xc(%eax),%edx
80101094:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101097:	8b 50 10             	mov    0x10(%eax),%edx
8010109a:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010109d:	8b 40 14             	mov    0x14(%eax),%eax
801010a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010a3:	8b 45 08             	mov    0x8(%ebp),%eax
801010a6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010ad:	8b 45 08             	mov    0x8(%ebp),%eax
801010b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010b6:	83 ec 0c             	sub    $0xc,%esp
801010b9:	68 80 de 10 80       	push   $0x8010de80
801010be:	e8 6a 3b 00 00       	call   80104c2d <release>
801010c3:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010c9:	83 f8 01             	cmp    $0x1,%eax
801010cc:	75 19                	jne    801010e7 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010ce:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010d2:	0f be d0             	movsbl %al,%edx
801010d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010d8:	83 ec 08             	sub    $0x8,%esp
801010db:	52                   	push   %edx
801010dc:	50                   	push   %eax
801010dd:	e8 b8 2c 00 00       	call   80103d9a <pipeclose>
801010e2:	83 c4 10             	add    $0x10,%esp
801010e5:	eb 21                	jmp    80101108 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801010e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010ea:	83 f8 02             	cmp    $0x2,%eax
801010ed:	75 19                	jne    80101108 <fileclose+0xe6>
    begin_trans();
801010ef:	e8 87 21 00 00       	call   8010327b <begin_trans>
    iput(ff.ip);
801010f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010f7:	83 ec 0c             	sub    $0xc,%esp
801010fa:	50                   	push   %eax
801010fb:	e8 c1 09 00 00       	call   80101ac1 <iput>
80101100:	83 c4 10             	add    $0x10,%esp
    commit_trans();
80101103:	e8 c6 21 00 00       	call   801032ce <commit_trans>
  }
}
80101108:	c9                   	leave  
80101109:	c3                   	ret    

8010110a <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010110a:	55                   	push   %ebp
8010110b:	89 e5                	mov    %esp,%ebp
8010110d:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101110:	8b 45 08             	mov    0x8(%ebp),%eax
80101113:	8b 00                	mov    (%eax),%eax
80101115:	83 f8 02             	cmp    $0x2,%eax
80101118:	75 40                	jne    8010115a <filestat+0x50>
    ilock(f->ip);
8010111a:	8b 45 08             	mov    0x8(%ebp),%eax
8010111d:	8b 40 10             	mov    0x10(%eax),%eax
80101120:	83 ec 0c             	sub    $0xc,%esp
80101123:	50                   	push   %eax
80101124:	e8 ce 07 00 00       	call   801018f7 <ilock>
80101129:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010112c:	8b 45 08             	mov    0x8(%ebp),%eax
8010112f:	8b 40 10             	mov    0x10(%eax),%eax
80101132:	83 ec 08             	sub    $0x8,%esp
80101135:	ff 75 0c             	pushl  0xc(%ebp)
80101138:	50                   	push   %eax
80101139:	e8 db 0c 00 00       	call   80101e19 <stati>
8010113e:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101141:	8b 45 08             	mov    0x8(%ebp),%eax
80101144:	8b 40 10             	mov    0x10(%eax),%eax
80101147:	83 ec 0c             	sub    $0xc,%esp
8010114a:	50                   	push   %eax
8010114b:	e8 ff 08 00 00       	call   80101a4f <iunlock>
80101150:	83 c4 10             	add    $0x10,%esp
    return 0;
80101153:	b8 00 00 00 00       	mov    $0x0,%eax
80101158:	eb 05                	jmp    8010115f <filestat+0x55>
  }
  return -1;
8010115a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010115f:	c9                   	leave  
80101160:	c3                   	ret    

80101161 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101161:	55                   	push   %ebp
80101162:	89 e5                	mov    %esp,%ebp
80101164:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101167:	8b 45 08             	mov    0x8(%ebp),%eax
8010116a:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010116e:	84 c0                	test   %al,%al
80101170:	75 0a                	jne    8010117c <fileread+0x1b>
    return -1;
80101172:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101177:	e9 9b 00 00 00       	jmp    80101217 <fileread+0xb6>
  if(f->type == FD_PIPE)
8010117c:	8b 45 08             	mov    0x8(%ebp),%eax
8010117f:	8b 00                	mov    (%eax),%eax
80101181:	83 f8 01             	cmp    $0x1,%eax
80101184:	75 1a                	jne    801011a0 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101186:	8b 45 08             	mov    0x8(%ebp),%eax
80101189:	8b 40 0c             	mov    0xc(%eax),%eax
8010118c:	83 ec 04             	sub    $0x4,%esp
8010118f:	ff 75 10             	pushl  0x10(%ebp)
80101192:	ff 75 0c             	pushl  0xc(%ebp)
80101195:	50                   	push   %eax
80101196:	e8 a7 2d 00 00       	call   80103f42 <piperead>
8010119b:	83 c4 10             	add    $0x10,%esp
8010119e:	eb 77                	jmp    80101217 <fileread+0xb6>
  if(f->type == FD_INODE){
801011a0:	8b 45 08             	mov    0x8(%ebp),%eax
801011a3:	8b 00                	mov    (%eax),%eax
801011a5:	83 f8 02             	cmp    $0x2,%eax
801011a8:	75 60                	jne    8010120a <fileread+0xa9>
    ilock(f->ip);
801011aa:	8b 45 08             	mov    0x8(%ebp),%eax
801011ad:	8b 40 10             	mov    0x10(%eax),%eax
801011b0:	83 ec 0c             	sub    $0xc,%esp
801011b3:	50                   	push   %eax
801011b4:	e8 3e 07 00 00       	call   801018f7 <ilock>
801011b9:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 50 14             	mov    0x14(%eax),%edx
801011c5:	8b 45 08             	mov    0x8(%ebp),%eax
801011c8:	8b 40 10             	mov    0x10(%eax),%eax
801011cb:	51                   	push   %ecx
801011cc:	52                   	push   %edx
801011cd:	ff 75 0c             	pushl  0xc(%ebp)
801011d0:	50                   	push   %eax
801011d1:	e8 89 0c 00 00       	call   80101e5f <readi>
801011d6:	83 c4 10             	add    $0x10,%esp
801011d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011e0:	7e 11                	jle    801011f3 <fileread+0x92>
      f->off += r;
801011e2:	8b 45 08             	mov    0x8(%ebp),%eax
801011e5:	8b 50 14             	mov    0x14(%eax),%edx
801011e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011eb:	01 c2                	add    %eax,%edx
801011ed:	8b 45 08             	mov    0x8(%ebp),%eax
801011f0:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011f3:	8b 45 08             	mov    0x8(%ebp),%eax
801011f6:	8b 40 10             	mov    0x10(%eax),%eax
801011f9:	83 ec 0c             	sub    $0xc,%esp
801011fc:	50                   	push   %eax
801011fd:	e8 4d 08 00 00       	call   80101a4f <iunlock>
80101202:	83 c4 10             	add    $0x10,%esp
    return r;
80101205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101208:	eb 0d                	jmp    80101217 <fileread+0xb6>
  }
  panic("fileread");
8010120a:	83 ec 0c             	sub    $0xc,%esp
8010120d:	68 f6 81 10 80       	push   $0x801081f6
80101212:	e8 4f f3 ff ff       	call   80100566 <panic>
}
80101217:	c9                   	leave  
80101218:	c3                   	ret    

80101219 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101219:	55                   	push   %ebp
8010121a:	89 e5                	mov    %esp,%ebp
8010121c:	53                   	push   %ebx
8010121d:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101220:	8b 45 08             	mov    0x8(%ebp),%eax
80101223:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101227:	84 c0                	test   %al,%al
80101229:	75 0a                	jne    80101235 <filewrite+0x1c>
    return -1;
8010122b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101230:	e9 1b 01 00 00       	jmp    80101350 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101235:	8b 45 08             	mov    0x8(%ebp),%eax
80101238:	8b 00                	mov    (%eax),%eax
8010123a:	83 f8 01             	cmp    $0x1,%eax
8010123d:	75 1d                	jne    8010125c <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010123f:	8b 45 08             	mov    0x8(%ebp),%eax
80101242:	8b 40 0c             	mov    0xc(%eax),%eax
80101245:	83 ec 04             	sub    $0x4,%esp
80101248:	ff 75 10             	pushl  0x10(%ebp)
8010124b:	ff 75 0c             	pushl  0xc(%ebp)
8010124e:	50                   	push   %eax
8010124f:	e8 f0 2b 00 00       	call   80103e44 <pipewrite>
80101254:	83 c4 10             	add    $0x10,%esp
80101257:	e9 f4 00 00 00       	jmp    80101350 <filewrite+0x137>
  if(f->type == FD_INODE){
8010125c:	8b 45 08             	mov    0x8(%ebp),%eax
8010125f:	8b 00                	mov    (%eax),%eax
80101261:	83 f8 02             	cmp    $0x2,%eax
80101264:	0f 85 d9 00 00 00    	jne    80101343 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010126a:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101271:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101278:	e9 a3 00 00 00       	jmp    80101320 <filewrite+0x107>
      int n1 = n - i;
8010127d:	8b 45 10             	mov    0x10(%ebp),%eax
80101280:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101283:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101286:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101289:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010128c:	7e 06                	jle    80101294 <filewrite+0x7b>
        n1 = max;
8010128e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101291:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
80101294:	e8 e2 1f 00 00       	call   8010327b <begin_trans>
      ilock(f->ip);
80101299:	8b 45 08             	mov    0x8(%ebp),%eax
8010129c:	8b 40 10             	mov    0x10(%eax),%eax
8010129f:	83 ec 0c             	sub    $0xc,%esp
801012a2:	50                   	push   %eax
801012a3:	e8 4f 06 00 00       	call   801018f7 <ilock>
801012a8:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012ab:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 50 14             	mov    0x14(%eax),%edx
801012b4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801012ba:	01 c3                	add    %eax,%ebx
801012bc:	8b 45 08             	mov    0x8(%ebp),%eax
801012bf:	8b 40 10             	mov    0x10(%eax),%eax
801012c2:	51                   	push   %ecx
801012c3:	52                   	push   %edx
801012c4:	53                   	push   %ebx
801012c5:	50                   	push   %eax
801012c6:	e8 eb 0c 00 00       	call   80101fb6 <writei>
801012cb:	83 c4 10             	add    $0x10,%esp
801012ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012d1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012d5:	7e 11                	jle    801012e8 <filewrite+0xcf>
        f->off += r;
801012d7:	8b 45 08             	mov    0x8(%ebp),%eax
801012da:	8b 50 14             	mov    0x14(%eax),%edx
801012dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012e0:	01 c2                	add    %eax,%edx
801012e2:	8b 45 08             	mov    0x8(%ebp),%eax
801012e5:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012e8:	8b 45 08             	mov    0x8(%ebp),%eax
801012eb:	8b 40 10             	mov    0x10(%eax),%eax
801012ee:	83 ec 0c             	sub    $0xc,%esp
801012f1:	50                   	push   %eax
801012f2:	e8 58 07 00 00       	call   80101a4f <iunlock>
801012f7:	83 c4 10             	add    $0x10,%esp
      commit_trans();
801012fa:	e8 cf 1f 00 00       	call   801032ce <commit_trans>

      if(r < 0)
801012ff:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101303:	78 29                	js     8010132e <filewrite+0x115>
        break;
      if(r != n1)
80101305:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101308:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010130b:	74 0d                	je     8010131a <filewrite+0x101>
        panic("short filewrite");
8010130d:	83 ec 0c             	sub    $0xc,%esp
80101310:	68 ff 81 10 80       	push   $0x801081ff
80101315:	e8 4c f2 ff ff       	call   80100566 <panic>
      i += r;
8010131a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010131d:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101323:	3b 45 10             	cmp    0x10(%ebp),%eax
80101326:	0f 8c 51 ff ff ff    	jl     8010127d <filewrite+0x64>
8010132c:	eb 01                	jmp    8010132f <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
8010132e:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010132f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101332:	3b 45 10             	cmp    0x10(%ebp),%eax
80101335:	75 05                	jne    8010133c <filewrite+0x123>
80101337:	8b 45 10             	mov    0x10(%ebp),%eax
8010133a:	eb 14                	jmp    80101350 <filewrite+0x137>
8010133c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101341:	eb 0d                	jmp    80101350 <filewrite+0x137>
  }
  panic("filewrite");
80101343:	83 ec 0c             	sub    $0xc,%esp
80101346:	68 0f 82 10 80       	push   $0x8010820f
8010134b:	e8 16 f2 ff ff       	call   80100566 <panic>
}
80101350:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101353:	c9                   	leave  
80101354:	c3                   	ret    

80101355 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101355:	55                   	push   %ebp
80101356:	89 e5                	mov    %esp,%ebp
80101358:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	83 ec 08             	sub    $0x8,%esp
80101361:	6a 01                	push   $0x1
80101363:	50                   	push   %eax
80101364:	e8 4d ee ff ff       	call   801001b6 <bread>
80101369:	83 c4 10             	add    $0x10,%esp
8010136c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010136f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101372:	83 c0 18             	add    $0x18,%eax
80101375:	83 ec 04             	sub    $0x4,%esp
80101378:	6a 10                	push   $0x10
8010137a:	50                   	push   %eax
8010137b:	ff 75 0c             	pushl  0xc(%ebp)
8010137e:	e8 65 3b 00 00       	call   80104ee8 <memmove>
80101383:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101386:	83 ec 0c             	sub    $0xc,%esp
80101389:	ff 75 f4             	pushl  -0xc(%ebp)
8010138c:	e8 9d ee ff ff       	call   8010022e <brelse>
80101391:	83 c4 10             	add    $0x10,%esp
}
80101394:	90                   	nop
80101395:	c9                   	leave  
80101396:	c3                   	ret    

80101397 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101397:	55                   	push   %ebp
80101398:	89 e5                	mov    %esp,%ebp
8010139a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010139d:	8b 55 0c             	mov    0xc(%ebp),%edx
801013a0:	8b 45 08             	mov    0x8(%ebp),%eax
801013a3:	83 ec 08             	sub    $0x8,%esp
801013a6:	52                   	push   %edx
801013a7:	50                   	push   %eax
801013a8:	e8 09 ee ff ff       	call   801001b6 <bread>
801013ad:	83 c4 10             	add    $0x10,%esp
801013b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b6:	83 c0 18             	add    $0x18,%eax
801013b9:	83 ec 04             	sub    $0x4,%esp
801013bc:	68 00 02 00 00       	push   $0x200
801013c1:	6a 00                	push   $0x0
801013c3:	50                   	push   %eax
801013c4:	e8 60 3a 00 00       	call   80104e29 <memset>
801013c9:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801013cc:	83 ec 0c             	sub    $0xc,%esp
801013cf:	ff 75 f4             	pushl  -0xc(%ebp)
801013d2:	e8 5c 1f 00 00       	call   80103333 <log_write>
801013d7:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013da:	83 ec 0c             	sub    $0xc,%esp
801013dd:	ff 75 f4             	pushl  -0xc(%ebp)
801013e0:	e8 49 ee ff ff       	call   8010022e <brelse>
801013e5:	83 c4 10             	add    $0x10,%esp
}
801013e8:	90                   	nop
801013e9:	c9                   	leave  
801013ea:	c3                   	ret    

801013eb <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013eb:	55                   	push   %ebp
801013ec:	89 e5                	mov    %esp,%ebp
801013ee:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801013f1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801013f8:	8b 45 08             	mov    0x8(%ebp),%eax
801013fb:	83 ec 08             	sub    $0x8,%esp
801013fe:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101401:	52                   	push   %edx
80101402:	50                   	push   %eax
80101403:	e8 4d ff ff ff       	call   80101355 <readsb>
80101408:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010140b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101412:	e9 15 01 00 00       	jmp    8010152c <balloc+0x141>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
80101417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010141a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101420:	85 c0                	test   %eax,%eax
80101422:	0f 48 c2             	cmovs  %edx,%eax
80101425:	c1 f8 0c             	sar    $0xc,%eax
80101428:	89 c2                	mov    %eax,%edx
8010142a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010142d:	c1 e8 03             	shr    $0x3,%eax
80101430:	01 d0                	add    %edx,%eax
80101432:	83 c0 03             	add    $0x3,%eax
80101435:	83 ec 08             	sub    $0x8,%esp
80101438:	50                   	push   %eax
80101439:	ff 75 08             	pushl  0x8(%ebp)
8010143c:	e8 75 ed ff ff       	call   801001b6 <bread>
80101441:	83 c4 10             	add    $0x10,%esp
80101444:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101447:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010144e:	e9 a6 00 00 00       	jmp    801014f9 <balloc+0x10e>
      m = 1 << (bi % 8);
80101453:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101456:	99                   	cltd   
80101457:	c1 ea 1d             	shr    $0x1d,%edx
8010145a:	01 d0                	add    %edx,%eax
8010145c:	83 e0 07             	and    $0x7,%eax
8010145f:	29 d0                	sub    %edx,%eax
80101461:	ba 01 00 00 00       	mov    $0x1,%edx
80101466:	89 c1                	mov    %eax,%ecx
80101468:	d3 e2                	shl    %cl,%edx
8010146a:	89 d0                	mov    %edx,%eax
8010146c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010146f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101472:	8d 50 07             	lea    0x7(%eax),%edx
80101475:	85 c0                	test   %eax,%eax
80101477:	0f 48 c2             	cmovs  %edx,%eax
8010147a:	c1 f8 03             	sar    $0x3,%eax
8010147d:	89 c2                	mov    %eax,%edx
8010147f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101482:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101487:	0f b6 c0             	movzbl %al,%eax
8010148a:	23 45 e8             	and    -0x18(%ebp),%eax
8010148d:	85 c0                	test   %eax,%eax
8010148f:	75 64                	jne    801014f5 <balloc+0x10a>
        bp->data[bi/8] |= m;  // Mark block in use.
80101491:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101494:	8d 50 07             	lea    0x7(%eax),%edx
80101497:	85 c0                	test   %eax,%eax
80101499:	0f 48 c2             	cmovs  %edx,%eax
8010149c:	c1 f8 03             	sar    $0x3,%eax
8010149f:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014a2:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014a7:	89 d1                	mov    %edx,%ecx
801014a9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014ac:	09 ca                	or     %ecx,%edx
801014ae:	89 d1                	mov    %edx,%ecx
801014b0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014b3:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014b7:	83 ec 0c             	sub    $0xc,%esp
801014ba:	ff 75 ec             	pushl  -0x14(%ebp)
801014bd:	e8 71 1e 00 00       	call   80103333 <log_write>
801014c2:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014c5:	83 ec 0c             	sub    $0xc,%esp
801014c8:	ff 75 ec             	pushl  -0x14(%ebp)
801014cb:	e8 5e ed ff ff       	call   8010022e <brelse>
801014d0:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d9:	01 c2                	add    %eax,%edx
801014db:	8b 45 08             	mov    0x8(%ebp),%eax
801014de:	83 ec 08             	sub    $0x8,%esp
801014e1:	52                   	push   %edx
801014e2:	50                   	push   %eax
801014e3:	e8 af fe ff ff       	call   80101397 <bzero>
801014e8:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801014eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f1:	01 d0                	add    %edx,%eax
801014f3:	eb 52                	jmp    80101547 <balloc+0x15c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014f5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014f9:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101500:	7f 15                	jg     80101517 <balloc+0x12c>
80101502:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101505:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101508:	01 d0                	add    %edx,%eax
8010150a:	89 c2                	mov    %eax,%edx
8010150c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010150f:	39 c2                	cmp    %eax,%edx
80101511:	0f 82 3c ff ff ff    	jb     80101453 <balloc+0x68>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101517:	83 ec 0c             	sub    $0xc,%esp
8010151a:	ff 75 ec             	pushl  -0x14(%ebp)
8010151d:	e8 0c ed ff ff       	call   8010022e <brelse>
80101522:	83 c4 10             	add    $0x10,%esp
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101525:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010152c:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010152f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101532:	39 c2                	cmp    %eax,%edx
80101534:	0f 87 dd fe ff ff    	ja     80101417 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010153a:	83 ec 0c             	sub    $0xc,%esp
8010153d:	68 19 82 10 80       	push   $0x80108219
80101542:	e8 1f f0 ff ff       	call   80100566 <panic>
}
80101547:	c9                   	leave  
80101548:	c3                   	ret    

80101549 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101549:	55                   	push   %ebp
8010154a:	89 e5                	mov    %esp,%ebp
8010154c:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
8010154f:	83 ec 08             	sub    $0x8,%esp
80101552:	8d 45 dc             	lea    -0x24(%ebp),%eax
80101555:	50                   	push   %eax
80101556:	ff 75 08             	pushl  0x8(%ebp)
80101559:	e8 f7 fd ff ff       	call   80101355 <readsb>
8010155e:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101561:	8b 45 0c             	mov    0xc(%ebp),%eax
80101564:	c1 e8 0c             	shr    $0xc,%eax
80101567:	89 c2                	mov    %eax,%edx
80101569:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010156c:	c1 e8 03             	shr    $0x3,%eax
8010156f:	01 d0                	add    %edx,%eax
80101571:	8d 50 03             	lea    0x3(%eax),%edx
80101574:	8b 45 08             	mov    0x8(%ebp),%eax
80101577:	83 ec 08             	sub    $0x8,%esp
8010157a:	52                   	push   %edx
8010157b:	50                   	push   %eax
8010157c:	e8 35 ec ff ff       	call   801001b6 <bread>
80101581:	83 c4 10             	add    $0x10,%esp
80101584:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101587:	8b 45 0c             	mov    0xc(%ebp),%eax
8010158a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010158f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101592:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101595:	99                   	cltd   
80101596:	c1 ea 1d             	shr    $0x1d,%edx
80101599:	01 d0                	add    %edx,%eax
8010159b:	83 e0 07             	and    $0x7,%eax
8010159e:	29 d0                	sub    %edx,%eax
801015a0:	ba 01 00 00 00       	mov    $0x1,%edx
801015a5:	89 c1                	mov    %eax,%ecx
801015a7:	d3 e2                	shl    %cl,%edx
801015a9:	89 d0                	mov    %edx,%eax
801015ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b1:	8d 50 07             	lea    0x7(%eax),%edx
801015b4:	85 c0                	test   %eax,%eax
801015b6:	0f 48 c2             	cmovs  %edx,%eax
801015b9:	c1 f8 03             	sar    $0x3,%eax
801015bc:	89 c2                	mov    %eax,%edx
801015be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015c1:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015c6:	0f b6 c0             	movzbl %al,%eax
801015c9:	23 45 ec             	and    -0x14(%ebp),%eax
801015cc:	85 c0                	test   %eax,%eax
801015ce:	75 0d                	jne    801015dd <bfree+0x94>
    panic("freeing free block");
801015d0:	83 ec 0c             	sub    $0xc,%esp
801015d3:	68 2f 82 10 80       	push   $0x8010822f
801015d8:	e8 89 ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801015dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e0:	8d 50 07             	lea    0x7(%eax),%edx
801015e3:	85 c0                	test   %eax,%eax
801015e5:	0f 48 c2             	cmovs  %edx,%eax
801015e8:	c1 f8 03             	sar    $0x3,%eax
801015eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ee:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801015f3:	89 d1                	mov    %edx,%ecx
801015f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015f8:	f7 d2                	not    %edx
801015fa:	21 ca                	and    %ecx,%edx
801015fc:	89 d1                	mov    %edx,%ecx
801015fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101601:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101605:	83 ec 0c             	sub    $0xc,%esp
80101608:	ff 75 f4             	pushl  -0xc(%ebp)
8010160b:	e8 23 1d 00 00       	call   80103333 <log_write>
80101610:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101613:	83 ec 0c             	sub    $0xc,%esp
80101616:	ff 75 f4             	pushl  -0xc(%ebp)
80101619:	e8 10 ec ff ff       	call   8010022e <brelse>
8010161e:	83 c4 10             	add    $0x10,%esp
}
80101621:	90                   	nop
80101622:	c9                   	leave  
80101623:	c3                   	ret    

80101624 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101624:	55                   	push   %ebp
80101625:	89 e5                	mov    %esp,%ebp
80101627:	83 ec 08             	sub    $0x8,%esp
  initlock(&icache.lock, "icache");
8010162a:	83 ec 08             	sub    $0x8,%esp
8010162d:	68 42 82 10 80       	push   $0x80108242
80101632:	68 80 e8 10 80       	push   $0x8010e880
80101637:	e8 68 35 00 00       	call   80104ba4 <initlock>
8010163c:	83 c4 10             	add    $0x10,%esp
}
8010163f:	90                   	nop
80101640:	c9                   	leave  
80101641:	c3                   	ret    

80101642 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101642:	55                   	push   %ebp
80101643:	89 e5                	mov    %esp,%ebp
80101645:	83 ec 38             	sub    $0x38,%esp
80101648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010164b:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
8010164f:	8b 45 08             	mov    0x8(%ebp),%eax
80101652:	83 ec 08             	sub    $0x8,%esp
80101655:	8d 55 dc             	lea    -0x24(%ebp),%edx
80101658:	52                   	push   %edx
80101659:	50                   	push   %eax
8010165a:	e8 f6 fc ff ff       	call   80101355 <readsb>
8010165f:	83 c4 10             	add    $0x10,%esp

  for(inum = 1; inum < sb.ninodes; inum++){
80101662:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101669:	e9 98 00 00 00       	jmp    80101706 <ialloc+0xc4>
    bp = bread(dev, IBLOCK(inum));
8010166e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101671:	c1 e8 03             	shr    $0x3,%eax
80101674:	83 c0 02             	add    $0x2,%eax
80101677:	83 ec 08             	sub    $0x8,%esp
8010167a:	50                   	push   %eax
8010167b:	ff 75 08             	pushl  0x8(%ebp)
8010167e:	e8 33 eb ff ff       	call   801001b6 <bread>
80101683:	83 c4 10             	add    $0x10,%esp
80101686:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101689:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010168c:	8d 50 18             	lea    0x18(%eax),%edx
8010168f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101692:	83 e0 07             	and    $0x7,%eax
80101695:	c1 e0 06             	shl    $0x6,%eax
80101698:	01 d0                	add    %edx,%eax
8010169a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010169d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016a0:	0f b7 00             	movzwl (%eax),%eax
801016a3:	66 85 c0             	test   %ax,%ax
801016a6:	75 4c                	jne    801016f4 <ialloc+0xb2>
      memset(dip, 0, sizeof(*dip));
801016a8:	83 ec 04             	sub    $0x4,%esp
801016ab:	6a 40                	push   $0x40
801016ad:	6a 00                	push   $0x0
801016af:	ff 75 ec             	pushl  -0x14(%ebp)
801016b2:	e8 72 37 00 00       	call   80104e29 <memset>
801016b7:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801016ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016bd:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801016c1:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801016c4:	83 ec 0c             	sub    $0xc,%esp
801016c7:	ff 75 f0             	pushl  -0x10(%ebp)
801016ca:	e8 64 1c 00 00       	call   80103333 <log_write>
801016cf:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801016d2:	83 ec 0c             	sub    $0xc,%esp
801016d5:	ff 75 f0             	pushl  -0x10(%ebp)
801016d8:	e8 51 eb ff ff       	call   8010022e <brelse>
801016dd:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801016e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e3:	83 ec 08             	sub    $0x8,%esp
801016e6:	50                   	push   %eax
801016e7:	ff 75 08             	pushl  0x8(%ebp)
801016ea:	e8 ef 00 00 00       	call   801017de <iget>
801016ef:	83 c4 10             	add    $0x10,%esp
801016f2:	eb 2d                	jmp    80101721 <ialloc+0xdf>
    }
    brelse(bp);
801016f4:	83 ec 0c             	sub    $0xc,%esp
801016f7:	ff 75 f0             	pushl  -0x10(%ebp)
801016fa:	e8 2f eb ff ff       	call   8010022e <brelse>
801016ff:	83 c4 10             	add    $0x10,%esp
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
80101702:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101706:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010170c:	39 c2                	cmp    %eax,%edx
8010170e:	0f 87 5a ff ff ff    	ja     8010166e <ialloc+0x2c>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101714:	83 ec 0c             	sub    $0xc,%esp
80101717:	68 49 82 10 80       	push   $0x80108249
8010171c:	e8 45 ee ff ff       	call   80100566 <panic>
}
80101721:	c9                   	leave  
80101722:	c3                   	ret    

80101723 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101723:	55                   	push   %ebp
80101724:	89 e5                	mov    %esp,%ebp
80101726:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
80101729:	8b 45 08             	mov    0x8(%ebp),%eax
8010172c:	8b 40 04             	mov    0x4(%eax),%eax
8010172f:	c1 e8 03             	shr    $0x3,%eax
80101732:	8d 50 02             	lea    0x2(%eax),%edx
80101735:	8b 45 08             	mov    0x8(%ebp),%eax
80101738:	8b 00                	mov    (%eax),%eax
8010173a:	83 ec 08             	sub    $0x8,%esp
8010173d:	52                   	push   %edx
8010173e:	50                   	push   %eax
8010173f:	e8 72 ea ff ff       	call   801001b6 <bread>
80101744:	83 c4 10             	add    $0x10,%esp
80101747:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010174a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174d:	8d 50 18             	lea    0x18(%eax),%edx
80101750:	8b 45 08             	mov    0x8(%ebp),%eax
80101753:	8b 40 04             	mov    0x4(%eax),%eax
80101756:	83 e0 07             	and    $0x7,%eax
80101759:	c1 e0 06             	shl    $0x6,%eax
8010175c:	01 d0                	add    %edx,%eax
8010175e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101761:	8b 45 08             	mov    0x8(%ebp),%eax
80101764:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101768:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010176b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010176e:	8b 45 08             	mov    0x8(%ebp),%eax
80101771:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101775:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101778:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010177c:	8b 45 08             	mov    0x8(%ebp),%eax
8010177f:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101783:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101786:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010178a:	8b 45 08             	mov    0x8(%ebp),%eax
8010178d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101791:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101794:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101798:	8b 45 08             	mov    0x8(%ebp),%eax
8010179b:	8b 50 18             	mov    0x18(%eax),%edx
8010179e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a1:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017a4:	8b 45 08             	mov    0x8(%ebp),%eax
801017a7:	8d 50 1c             	lea    0x1c(%eax),%edx
801017aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017ad:	83 c0 0c             	add    $0xc,%eax
801017b0:	83 ec 04             	sub    $0x4,%esp
801017b3:	6a 34                	push   $0x34
801017b5:	52                   	push   %edx
801017b6:	50                   	push   %eax
801017b7:	e8 2c 37 00 00       	call   80104ee8 <memmove>
801017bc:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801017bf:	83 ec 0c             	sub    $0xc,%esp
801017c2:	ff 75 f4             	pushl  -0xc(%ebp)
801017c5:	e8 69 1b 00 00       	call   80103333 <log_write>
801017ca:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801017cd:	83 ec 0c             	sub    $0xc,%esp
801017d0:	ff 75 f4             	pushl  -0xc(%ebp)
801017d3:	e8 56 ea ff ff       	call   8010022e <brelse>
801017d8:	83 c4 10             	add    $0x10,%esp
}
801017db:	90                   	nop
801017dc:	c9                   	leave  
801017dd:	c3                   	ret    

801017de <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801017de:	55                   	push   %ebp
801017df:	89 e5                	mov    %esp,%ebp
801017e1:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801017e4:	83 ec 0c             	sub    $0xc,%esp
801017e7:	68 80 e8 10 80       	push   $0x8010e880
801017ec:	e8 d5 33 00 00       	call   80104bc6 <acquire>
801017f1:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801017f4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017fb:	c7 45 f4 b4 e8 10 80 	movl   $0x8010e8b4,-0xc(%ebp)
80101802:	eb 5d                	jmp    80101861 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101807:	8b 40 08             	mov    0x8(%eax),%eax
8010180a:	85 c0                	test   %eax,%eax
8010180c:	7e 39                	jle    80101847 <iget+0x69>
8010180e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101811:	8b 00                	mov    (%eax),%eax
80101813:	3b 45 08             	cmp    0x8(%ebp),%eax
80101816:	75 2f                	jne    80101847 <iget+0x69>
80101818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010181b:	8b 40 04             	mov    0x4(%eax),%eax
8010181e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101821:	75 24                	jne    80101847 <iget+0x69>
      ip->ref++;
80101823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101826:	8b 40 08             	mov    0x8(%eax),%eax
80101829:	8d 50 01             	lea    0x1(%eax),%edx
8010182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101832:	83 ec 0c             	sub    $0xc,%esp
80101835:	68 80 e8 10 80       	push   $0x8010e880
8010183a:	e8 ee 33 00 00       	call   80104c2d <release>
8010183f:	83 c4 10             	add    $0x10,%esp
      return ip;
80101842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101845:	eb 74                	jmp    801018bb <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101847:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010184b:	75 10                	jne    8010185d <iget+0x7f>
8010184d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101850:	8b 40 08             	mov    0x8(%eax),%eax
80101853:	85 c0                	test   %eax,%eax
80101855:	75 06                	jne    8010185d <iget+0x7f>
      empty = ip;
80101857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010185a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010185d:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101861:	81 7d f4 54 f8 10 80 	cmpl   $0x8010f854,-0xc(%ebp)
80101868:	72 9a                	jb     80101804 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010186a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010186e:	75 0d                	jne    8010187d <iget+0x9f>
    panic("iget: no inodes");
80101870:	83 ec 0c             	sub    $0xc,%esp
80101873:	68 5b 82 10 80       	push   $0x8010825b
80101878:	e8 e9 ec ff ff       	call   80100566 <panic>

  ip = empty;
8010187d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101880:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101886:	8b 55 08             	mov    0x8(%ebp),%edx
80101889:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010188b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101891:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101897:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010189e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801018a8:	83 ec 0c             	sub    $0xc,%esp
801018ab:	68 80 e8 10 80       	push   $0x8010e880
801018b0:	e8 78 33 00 00       	call   80104c2d <release>
801018b5:	83 c4 10             	add    $0x10,%esp

  return ip;
801018b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801018bb:	c9                   	leave  
801018bc:	c3                   	ret    

801018bd <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801018bd:	55                   	push   %ebp
801018be:	89 e5                	mov    %esp,%ebp
801018c0:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801018c3:	83 ec 0c             	sub    $0xc,%esp
801018c6:	68 80 e8 10 80       	push   $0x8010e880
801018cb:	e8 f6 32 00 00       	call   80104bc6 <acquire>
801018d0:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801018d3:	8b 45 08             	mov    0x8(%ebp),%eax
801018d6:	8b 40 08             	mov    0x8(%eax),%eax
801018d9:	8d 50 01             	lea    0x1(%eax),%edx
801018dc:	8b 45 08             	mov    0x8(%ebp),%eax
801018df:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801018e2:	83 ec 0c             	sub    $0xc,%esp
801018e5:	68 80 e8 10 80       	push   $0x8010e880
801018ea:	e8 3e 33 00 00       	call   80104c2d <release>
801018ef:	83 c4 10             	add    $0x10,%esp
  return ip;
801018f2:	8b 45 08             	mov    0x8(%ebp),%eax
}
801018f5:	c9                   	leave  
801018f6:	c3                   	ret    

801018f7 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801018f7:	55                   	push   %ebp
801018f8:	89 e5                	mov    %esp,%ebp
801018fa:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801018fd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101901:	74 0a                	je     8010190d <ilock+0x16>
80101903:	8b 45 08             	mov    0x8(%ebp),%eax
80101906:	8b 40 08             	mov    0x8(%eax),%eax
80101909:	85 c0                	test   %eax,%eax
8010190b:	7f 0d                	jg     8010191a <ilock+0x23>
    panic("ilock");
8010190d:	83 ec 0c             	sub    $0xc,%esp
80101910:	68 6b 82 10 80       	push   $0x8010826b
80101915:	e8 4c ec ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
8010191a:	83 ec 0c             	sub    $0xc,%esp
8010191d:	68 80 e8 10 80       	push   $0x8010e880
80101922:	e8 9f 32 00 00       	call   80104bc6 <acquire>
80101927:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
8010192a:	eb 13                	jmp    8010193f <ilock+0x48>
    sleep(ip, &icache.lock);
8010192c:	83 ec 08             	sub    $0x8,%esp
8010192f:	68 80 e8 10 80       	push   $0x8010e880
80101934:	ff 75 08             	pushl  0x8(%ebp)
80101937:	e8 91 2f 00 00       	call   801048cd <sleep>
8010193c:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
8010193f:	8b 45 08             	mov    0x8(%ebp),%eax
80101942:	8b 40 0c             	mov    0xc(%eax),%eax
80101945:	83 e0 01             	and    $0x1,%eax
80101948:	85 c0                	test   %eax,%eax
8010194a:	75 e0                	jne    8010192c <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
8010194c:	8b 45 08             	mov    0x8(%ebp),%eax
8010194f:	8b 40 0c             	mov    0xc(%eax),%eax
80101952:	83 c8 01             	or     $0x1,%eax
80101955:	89 c2                	mov    %eax,%edx
80101957:	8b 45 08             	mov    0x8(%ebp),%eax
8010195a:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
8010195d:	83 ec 0c             	sub    $0xc,%esp
80101960:	68 80 e8 10 80       	push   $0x8010e880
80101965:	e8 c3 32 00 00       	call   80104c2d <release>
8010196a:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
8010196d:	8b 45 08             	mov    0x8(%ebp),%eax
80101970:	8b 40 0c             	mov    0xc(%eax),%eax
80101973:	83 e0 02             	and    $0x2,%eax
80101976:	85 c0                	test   %eax,%eax
80101978:	0f 85 ce 00 00 00    	jne    80101a4c <ilock+0x155>
    bp = bread(ip->dev, IBLOCK(ip->inum));
8010197e:	8b 45 08             	mov    0x8(%ebp),%eax
80101981:	8b 40 04             	mov    0x4(%eax),%eax
80101984:	c1 e8 03             	shr    $0x3,%eax
80101987:	8d 50 02             	lea    0x2(%eax),%edx
8010198a:	8b 45 08             	mov    0x8(%ebp),%eax
8010198d:	8b 00                	mov    (%eax),%eax
8010198f:	83 ec 08             	sub    $0x8,%esp
80101992:	52                   	push   %edx
80101993:	50                   	push   %eax
80101994:	e8 1d e8 ff ff       	call   801001b6 <bread>
80101999:	83 c4 10             	add    $0x10,%esp
8010199c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010199f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a2:	8d 50 18             	lea    0x18(%eax),%edx
801019a5:	8b 45 08             	mov    0x8(%ebp),%eax
801019a8:	8b 40 04             	mov    0x4(%eax),%eax
801019ab:	83 e0 07             	and    $0x7,%eax
801019ae:	c1 e0 06             	shl    $0x6,%eax
801019b1:	01 d0                	add    %edx,%eax
801019b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801019b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b9:	0f b7 10             	movzwl (%eax),%edx
801019bc:	8b 45 08             	mov    0x8(%ebp),%eax
801019bf:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
801019c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c6:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019ca:	8b 45 08             	mov    0x8(%ebp),%eax
801019cd:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801019d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d4:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019d8:	8b 45 08             	mov    0x8(%ebp),%eax
801019db:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
801019df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e2:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801019e6:	8b 45 08             	mov    0x8(%ebp),%eax
801019e9:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
801019ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f0:	8b 50 08             	mov    0x8(%eax),%edx
801019f3:	8b 45 08             	mov    0x8(%ebp),%eax
801019f6:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019fc:	8d 50 0c             	lea    0xc(%eax),%edx
801019ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101a02:	83 c0 1c             	add    $0x1c,%eax
80101a05:	83 ec 04             	sub    $0x4,%esp
80101a08:	6a 34                	push   $0x34
80101a0a:	52                   	push   %edx
80101a0b:	50                   	push   %eax
80101a0c:	e8 d7 34 00 00       	call   80104ee8 <memmove>
80101a11:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a14:	83 ec 0c             	sub    $0xc,%esp
80101a17:	ff 75 f4             	pushl  -0xc(%ebp)
80101a1a:	e8 0f e8 ff ff       	call   8010022e <brelse>
80101a1f:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a22:	8b 45 08             	mov    0x8(%ebp),%eax
80101a25:	8b 40 0c             	mov    0xc(%eax),%eax
80101a28:	83 c8 02             	or     $0x2,%eax
80101a2b:	89 c2                	mov    %eax,%edx
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a33:	8b 45 08             	mov    0x8(%ebp),%eax
80101a36:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a3a:	66 85 c0             	test   %ax,%ax
80101a3d:	75 0d                	jne    80101a4c <ilock+0x155>
      panic("ilock: no type");
80101a3f:	83 ec 0c             	sub    $0xc,%esp
80101a42:	68 71 82 10 80       	push   $0x80108271
80101a47:	e8 1a eb ff ff       	call   80100566 <panic>
  }
}
80101a4c:	90                   	nop
80101a4d:	c9                   	leave  
80101a4e:	c3                   	ret    

80101a4f <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a4f:	55                   	push   %ebp
80101a50:	89 e5                	mov    %esp,%ebp
80101a52:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101a55:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a59:	74 17                	je     80101a72 <iunlock+0x23>
80101a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5e:	8b 40 0c             	mov    0xc(%eax),%eax
80101a61:	83 e0 01             	and    $0x1,%eax
80101a64:	85 c0                	test   %eax,%eax
80101a66:	74 0a                	je     80101a72 <iunlock+0x23>
80101a68:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6b:	8b 40 08             	mov    0x8(%eax),%eax
80101a6e:	85 c0                	test   %eax,%eax
80101a70:	7f 0d                	jg     80101a7f <iunlock+0x30>
    panic("iunlock");
80101a72:	83 ec 0c             	sub    $0xc,%esp
80101a75:	68 80 82 10 80       	push   $0x80108280
80101a7a:	e8 e7 ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a7f:	83 ec 0c             	sub    $0xc,%esp
80101a82:	68 80 e8 10 80       	push   $0x8010e880
80101a87:	e8 3a 31 00 00       	call   80104bc6 <acquire>
80101a8c:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a92:	8b 40 0c             	mov    0xc(%eax),%eax
80101a95:	83 e0 fe             	and    $0xfffffffe,%eax
80101a98:	89 c2                	mov    %eax,%edx
80101a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9d:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101aa0:	83 ec 0c             	sub    $0xc,%esp
80101aa3:	ff 75 08             	pushl  0x8(%ebp)
80101aa6:	e8 0d 2f 00 00       	call   801049b8 <wakeup>
80101aab:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101aae:	83 ec 0c             	sub    $0xc,%esp
80101ab1:	68 80 e8 10 80       	push   $0x8010e880
80101ab6:	e8 72 31 00 00       	call   80104c2d <release>
80101abb:	83 c4 10             	add    $0x10,%esp
}
80101abe:	90                   	nop
80101abf:	c9                   	leave  
80101ac0:	c3                   	ret    

80101ac1 <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101ac1:	55                   	push   %ebp
80101ac2:	89 e5                	mov    %esp,%ebp
80101ac4:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ac7:	83 ec 0c             	sub    $0xc,%esp
80101aca:	68 80 e8 10 80       	push   $0x8010e880
80101acf:	e8 f2 30 00 00       	call   80104bc6 <acquire>
80101ad4:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	8b 40 08             	mov    0x8(%eax),%eax
80101add:	83 f8 01             	cmp    $0x1,%eax
80101ae0:	0f 85 a9 00 00 00    	jne    80101b8f <iput+0xce>
80101ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae9:	8b 40 0c             	mov    0xc(%eax),%eax
80101aec:	83 e0 02             	and    $0x2,%eax
80101aef:	85 c0                	test   %eax,%eax
80101af1:	0f 84 98 00 00 00    	je     80101b8f <iput+0xce>
80101af7:	8b 45 08             	mov    0x8(%ebp),%eax
80101afa:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101afe:	66 85 c0             	test   %ax,%ax
80101b01:	0f 85 88 00 00 00    	jne    80101b8f <iput+0xce>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	8b 40 0c             	mov    0xc(%eax),%eax
80101b0d:	83 e0 01             	and    $0x1,%eax
80101b10:	85 c0                	test   %eax,%eax
80101b12:	74 0d                	je     80101b21 <iput+0x60>
      panic("iput busy");
80101b14:	83 ec 0c             	sub    $0xc,%esp
80101b17:	68 88 82 10 80       	push   $0x80108288
80101b1c:	e8 45 ea ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101b21:	8b 45 08             	mov    0x8(%ebp),%eax
80101b24:	8b 40 0c             	mov    0xc(%eax),%eax
80101b27:	83 c8 01             	or     $0x1,%eax
80101b2a:	89 c2                	mov    %eax,%edx
80101b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2f:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101b32:	83 ec 0c             	sub    $0xc,%esp
80101b35:	68 80 e8 10 80       	push   $0x8010e880
80101b3a:	e8 ee 30 00 00       	call   80104c2d <release>
80101b3f:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101b42:	83 ec 0c             	sub    $0xc,%esp
80101b45:	ff 75 08             	pushl  0x8(%ebp)
80101b48:	e8 a8 01 00 00       	call   80101cf5 <itrunc>
80101b4d:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101b50:	8b 45 08             	mov    0x8(%ebp),%eax
80101b53:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101b59:	83 ec 0c             	sub    $0xc,%esp
80101b5c:	ff 75 08             	pushl  0x8(%ebp)
80101b5f:	e8 bf fb ff ff       	call   80101723 <iupdate>
80101b64:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101b67:	83 ec 0c             	sub    $0xc,%esp
80101b6a:	68 80 e8 10 80       	push   $0x8010e880
80101b6f:	e8 52 30 00 00       	call   80104bc6 <acquire>
80101b74:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101b77:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101b81:	83 ec 0c             	sub    $0xc,%esp
80101b84:	ff 75 08             	pushl  0x8(%ebp)
80101b87:	e8 2c 2e 00 00       	call   801049b8 <wakeup>
80101b8c:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b92:	8b 40 08             	mov    0x8(%eax),%eax
80101b95:	8d 50 ff             	lea    -0x1(%eax),%edx
80101b98:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9b:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b9e:	83 ec 0c             	sub    $0xc,%esp
80101ba1:	68 80 e8 10 80       	push   $0x8010e880
80101ba6:	e8 82 30 00 00       	call   80104c2d <release>
80101bab:	83 c4 10             	add    $0x10,%esp
}
80101bae:	90                   	nop
80101baf:	c9                   	leave  
80101bb0:	c3                   	ret    

80101bb1 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101bb1:	55                   	push   %ebp
80101bb2:	89 e5                	mov    %esp,%ebp
80101bb4:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101bb7:	83 ec 0c             	sub    $0xc,%esp
80101bba:	ff 75 08             	pushl  0x8(%ebp)
80101bbd:	e8 8d fe ff ff       	call   80101a4f <iunlock>
80101bc2:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101bc5:	83 ec 0c             	sub    $0xc,%esp
80101bc8:	ff 75 08             	pushl  0x8(%ebp)
80101bcb:	e8 f1 fe ff ff       	call   80101ac1 <iput>
80101bd0:	83 c4 10             	add    $0x10,%esp
}
80101bd3:	90                   	nop
80101bd4:	c9                   	leave  
80101bd5:	c3                   	ret    

80101bd6 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101bd6:	55                   	push   %ebp
80101bd7:	89 e5                	mov    %esp,%ebp
80101bd9:	53                   	push   %ebx
80101bda:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101bdd:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101be1:	77 42                	ja     80101c25 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101be3:	8b 45 08             	mov    0x8(%ebp),%eax
80101be6:	8b 55 0c             	mov    0xc(%ebp),%edx
80101be9:	83 c2 04             	add    $0x4,%edx
80101bec:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101bf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bf3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bf7:	75 24                	jne    80101c1d <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 00                	mov    (%eax),%eax
80101bfe:	83 ec 0c             	sub    $0xc,%esp
80101c01:	50                   	push   %eax
80101c02:	e8 e4 f7 ff ff       	call   801013eb <balloc>
80101c07:	83 c4 10             	add    $0x10,%esp
80101c0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c10:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c13:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c19:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c20:	e9 cb 00 00 00       	jmp    80101cf0 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c25:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c29:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c2d:	0f 87 b0 00 00 00    	ja     80101ce3 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c33:	8b 45 08             	mov    0x8(%ebp),%eax
80101c36:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c39:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c40:	75 1d                	jne    80101c5f <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c42:	8b 45 08             	mov    0x8(%ebp),%eax
80101c45:	8b 00                	mov    (%eax),%eax
80101c47:	83 ec 0c             	sub    $0xc,%esp
80101c4a:	50                   	push   %eax
80101c4b:	e8 9b f7 ff ff       	call   801013eb <balloc>
80101c50:	83 c4 10             	add    $0x10,%esp
80101c53:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c56:	8b 45 08             	mov    0x8(%ebp),%eax
80101c59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c5c:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c62:	8b 00                	mov    (%eax),%eax
80101c64:	83 ec 08             	sub    $0x8,%esp
80101c67:	ff 75 f4             	pushl  -0xc(%ebp)
80101c6a:	50                   	push   %eax
80101c6b:	e8 46 e5 ff ff       	call   801001b6 <bread>
80101c70:	83 c4 10             	add    $0x10,%esp
80101c73:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c79:	83 c0 18             	add    $0x18,%eax
80101c7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c82:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c8c:	01 d0                	add    %edx,%eax
80101c8e:	8b 00                	mov    (%eax),%eax
80101c90:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c93:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c97:	75 37                	jne    80101cd0 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101c99:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c9c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ca3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ca6:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cac:	8b 00                	mov    (%eax),%eax
80101cae:	83 ec 0c             	sub    $0xc,%esp
80101cb1:	50                   	push   %eax
80101cb2:	e8 34 f7 ff ff       	call   801013eb <balloc>
80101cb7:	83 c4 10             	add    $0x10,%esp
80101cba:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cc0:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101cc2:	83 ec 0c             	sub    $0xc,%esp
80101cc5:	ff 75 f0             	pushl  -0x10(%ebp)
80101cc8:	e8 66 16 00 00       	call   80103333 <log_write>
80101ccd:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101cd0:	83 ec 0c             	sub    $0xc,%esp
80101cd3:	ff 75 f0             	pushl  -0x10(%ebp)
80101cd6:	e8 53 e5 ff ff       	call   8010022e <brelse>
80101cdb:	83 c4 10             	add    $0x10,%esp
    return addr;
80101cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ce1:	eb 0d                	jmp    80101cf0 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101ce3:	83 ec 0c             	sub    $0xc,%esp
80101ce6:	68 92 82 10 80       	push   $0x80108292
80101ceb:	e8 76 e8 ff ff       	call   80100566 <panic>
}
80101cf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101cf3:	c9                   	leave  
80101cf4:	c3                   	ret    

80101cf5 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101cf5:	55                   	push   %ebp
80101cf6:	89 e5                	mov    %esp,%ebp
80101cf8:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101cfb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d02:	eb 45                	jmp    80101d49 <itrunc+0x54>
    if(ip->addrs[i]){
80101d04:	8b 45 08             	mov    0x8(%ebp),%eax
80101d07:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d0a:	83 c2 04             	add    $0x4,%edx
80101d0d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d11:	85 c0                	test   %eax,%eax
80101d13:	74 30                	je     80101d45 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d15:	8b 45 08             	mov    0x8(%ebp),%eax
80101d18:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d1b:	83 c2 04             	add    $0x4,%edx
80101d1e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d22:	8b 55 08             	mov    0x8(%ebp),%edx
80101d25:	8b 12                	mov    (%edx),%edx
80101d27:	83 ec 08             	sub    $0x8,%esp
80101d2a:	50                   	push   %eax
80101d2b:	52                   	push   %edx
80101d2c:	e8 18 f8 ff ff       	call   80101549 <bfree>
80101d31:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d34:	8b 45 08             	mov    0x8(%ebp),%eax
80101d37:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d3a:	83 c2 04             	add    $0x4,%edx
80101d3d:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d44:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d45:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d49:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101d4d:	7e b5                	jle    80101d04 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101d4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d52:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d55:	85 c0                	test   %eax,%eax
80101d57:	0f 84 a1 00 00 00    	je     80101dfe <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101d5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d60:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d63:	8b 45 08             	mov    0x8(%ebp),%eax
80101d66:	8b 00                	mov    (%eax),%eax
80101d68:	83 ec 08             	sub    $0x8,%esp
80101d6b:	52                   	push   %edx
80101d6c:	50                   	push   %eax
80101d6d:	e8 44 e4 ff ff       	call   801001b6 <bread>
80101d72:	83 c4 10             	add    $0x10,%esp
80101d75:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d78:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d7b:	83 c0 18             	add    $0x18,%eax
80101d7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d81:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101d88:	eb 3c                	jmp    80101dc6 <itrunc+0xd1>
      if(a[j])
80101d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d94:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d97:	01 d0                	add    %edx,%eax
80101d99:	8b 00                	mov    (%eax),%eax
80101d9b:	85 c0                	test   %eax,%eax
80101d9d:	74 23                	je     80101dc2 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101d9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101da2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101da9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101dac:	01 d0                	add    %edx,%eax
80101dae:	8b 00                	mov    (%eax),%eax
80101db0:	8b 55 08             	mov    0x8(%ebp),%edx
80101db3:	8b 12                	mov    (%edx),%edx
80101db5:	83 ec 08             	sub    $0x8,%esp
80101db8:	50                   	push   %eax
80101db9:	52                   	push   %edx
80101dba:	e8 8a f7 ff ff       	call   80101549 <bfree>
80101dbf:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101dc2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101dc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dc9:	83 f8 7f             	cmp    $0x7f,%eax
80101dcc:	76 bc                	jbe    80101d8a <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101dce:	83 ec 0c             	sub    $0xc,%esp
80101dd1:	ff 75 ec             	pushl  -0x14(%ebp)
80101dd4:	e8 55 e4 ff ff       	call   8010022e <brelse>
80101dd9:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddf:	8b 40 4c             	mov    0x4c(%eax),%eax
80101de2:	8b 55 08             	mov    0x8(%ebp),%edx
80101de5:	8b 12                	mov    (%edx),%edx
80101de7:	83 ec 08             	sub    $0x8,%esp
80101dea:	50                   	push   %eax
80101deb:	52                   	push   %edx
80101dec:	e8 58 f7 ff ff       	call   80101549 <bfree>
80101df1:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101df4:	8b 45 08             	mov    0x8(%ebp),%eax
80101df7:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101e01:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e08:	83 ec 0c             	sub    $0xc,%esp
80101e0b:	ff 75 08             	pushl  0x8(%ebp)
80101e0e:	e8 10 f9 ff ff       	call   80101723 <iupdate>
80101e13:	83 c4 10             	add    $0x10,%esp
}
80101e16:	90                   	nop
80101e17:	c9                   	leave  
80101e18:	c3                   	ret    

80101e19 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e19:	55                   	push   %ebp
80101e1a:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1f:	8b 00                	mov    (%eax),%eax
80101e21:	89 c2                	mov    %eax,%edx
80101e23:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e26:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e29:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2c:	8b 50 04             	mov    0x4(%eax),%edx
80101e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e32:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e35:	8b 45 08             	mov    0x8(%ebp),%eax
80101e38:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e3f:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101e42:	8b 45 08             	mov    0x8(%ebp),%eax
80101e45:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101e49:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e4c:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101e50:	8b 45 08             	mov    0x8(%ebp),%eax
80101e53:	8b 50 18             	mov    0x18(%eax),%edx
80101e56:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e59:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e5c:	90                   	nop
80101e5d:	5d                   	pop    %ebp
80101e5e:	c3                   	ret    

80101e5f <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101e5f:	55                   	push   %ebp
80101e60:	89 e5                	mov    %esp,%ebp
80101e62:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101e65:	8b 45 08             	mov    0x8(%ebp),%eax
80101e68:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101e6c:	66 83 f8 03          	cmp    $0x3,%ax
80101e70:	75 5c                	jne    80101ece <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101e72:	8b 45 08             	mov    0x8(%ebp),%eax
80101e75:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e79:	66 85 c0             	test   %ax,%ax
80101e7c:	78 20                	js     80101e9e <readi+0x3f>
80101e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e81:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e85:	66 83 f8 09          	cmp    $0x9,%ax
80101e89:	7f 13                	jg     80101e9e <readi+0x3f>
80101e8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e92:	98                   	cwtl   
80101e93:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
80101e9a:	85 c0                	test   %eax,%eax
80101e9c:	75 0a                	jne    80101ea8 <readi+0x49>
      return -1;
80101e9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ea3:	e9 0c 01 00 00       	jmp    80101fb4 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80101eab:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eaf:	98                   	cwtl   
80101eb0:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
80101eb7:	8b 55 14             	mov    0x14(%ebp),%edx
80101eba:	83 ec 04             	sub    $0x4,%esp
80101ebd:	52                   	push   %edx
80101ebe:	ff 75 0c             	pushl  0xc(%ebp)
80101ec1:	ff 75 08             	pushl  0x8(%ebp)
80101ec4:	ff d0                	call   *%eax
80101ec6:	83 c4 10             	add    $0x10,%esp
80101ec9:	e9 e6 00 00 00       	jmp    80101fb4 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101ece:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed1:	8b 40 18             	mov    0x18(%eax),%eax
80101ed4:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ed7:	72 0d                	jb     80101ee6 <readi+0x87>
80101ed9:	8b 55 10             	mov    0x10(%ebp),%edx
80101edc:	8b 45 14             	mov    0x14(%ebp),%eax
80101edf:	01 d0                	add    %edx,%eax
80101ee1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ee4:	73 0a                	jae    80101ef0 <readi+0x91>
    return -1;
80101ee6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101eeb:	e9 c4 00 00 00       	jmp    80101fb4 <readi+0x155>
  if(off + n > ip->size)
80101ef0:	8b 55 10             	mov    0x10(%ebp),%edx
80101ef3:	8b 45 14             	mov    0x14(%ebp),%eax
80101ef6:	01 c2                	add    %eax,%edx
80101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80101efb:	8b 40 18             	mov    0x18(%eax),%eax
80101efe:	39 c2                	cmp    %eax,%edx
80101f00:	76 0c                	jbe    80101f0e <readi+0xaf>
    n = ip->size - off;
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	8b 40 18             	mov    0x18(%eax),%eax
80101f08:	2b 45 10             	sub    0x10(%ebp),%eax
80101f0b:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f15:	e9 8b 00 00 00       	jmp    80101fa5 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f1a:	8b 45 10             	mov    0x10(%ebp),%eax
80101f1d:	c1 e8 09             	shr    $0x9,%eax
80101f20:	83 ec 08             	sub    $0x8,%esp
80101f23:	50                   	push   %eax
80101f24:	ff 75 08             	pushl  0x8(%ebp)
80101f27:	e8 aa fc ff ff       	call   80101bd6 <bmap>
80101f2c:	83 c4 10             	add    $0x10,%esp
80101f2f:	89 c2                	mov    %eax,%edx
80101f31:	8b 45 08             	mov    0x8(%ebp),%eax
80101f34:	8b 00                	mov    (%eax),%eax
80101f36:	83 ec 08             	sub    $0x8,%esp
80101f39:	52                   	push   %edx
80101f3a:	50                   	push   %eax
80101f3b:	e8 76 e2 ff ff       	call   801001b6 <bread>
80101f40:	83 c4 10             	add    $0x10,%esp
80101f43:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101f46:	8b 45 10             	mov    0x10(%ebp),%eax
80101f49:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f4e:	ba 00 02 00 00       	mov    $0x200,%edx
80101f53:	29 c2                	sub    %eax,%edx
80101f55:	8b 45 14             	mov    0x14(%ebp),%eax
80101f58:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101f5b:	39 c2                	cmp    %eax,%edx
80101f5d:	0f 46 c2             	cmovbe %edx,%eax
80101f60:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f66:	8d 50 18             	lea    0x18(%eax),%edx
80101f69:	8b 45 10             	mov    0x10(%ebp),%eax
80101f6c:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f71:	01 d0                	add    %edx,%eax
80101f73:	83 ec 04             	sub    $0x4,%esp
80101f76:	ff 75 ec             	pushl  -0x14(%ebp)
80101f79:	50                   	push   %eax
80101f7a:	ff 75 0c             	pushl  0xc(%ebp)
80101f7d:	e8 66 2f 00 00       	call   80104ee8 <memmove>
80101f82:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101f85:	83 ec 0c             	sub    $0xc,%esp
80101f88:	ff 75 f0             	pushl  -0x10(%ebp)
80101f8b:	e8 9e e2 ff ff       	call   8010022e <brelse>
80101f90:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f96:	01 45 f4             	add    %eax,-0xc(%ebp)
80101f99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f9c:	01 45 10             	add    %eax,0x10(%ebp)
80101f9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fa2:	01 45 0c             	add    %eax,0xc(%ebp)
80101fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fa8:	3b 45 14             	cmp    0x14(%ebp),%eax
80101fab:	0f 82 69 ff ff ff    	jb     80101f1a <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101fb1:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101fb4:	c9                   	leave  
80101fb5:	c3                   	ret    

80101fb6 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101fb6:	55                   	push   %ebp
80101fb7:	89 e5                	mov    %esp,%ebp
80101fb9:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101fc3:	66 83 f8 03          	cmp    $0x3,%ax
80101fc7:	75 5c                	jne    80102025 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fcc:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fd0:	66 85 c0             	test   %ax,%ax
80101fd3:	78 20                	js     80101ff5 <writei+0x3f>
80101fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd8:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fdc:	66 83 f8 09          	cmp    $0x9,%ax
80101fe0:	7f 13                	jg     80101ff5 <writei+0x3f>
80101fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fe9:	98                   	cwtl   
80101fea:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
80101ff1:	85 c0                	test   %eax,%eax
80101ff3:	75 0a                	jne    80101fff <writei+0x49>
      return -1;
80101ff5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ffa:	e9 3d 01 00 00       	jmp    8010213c <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80101fff:	8b 45 08             	mov    0x8(%ebp),%eax
80102002:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102006:	98                   	cwtl   
80102007:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
8010200e:	8b 55 14             	mov    0x14(%ebp),%edx
80102011:	83 ec 04             	sub    $0x4,%esp
80102014:	52                   	push   %edx
80102015:	ff 75 0c             	pushl  0xc(%ebp)
80102018:	ff 75 08             	pushl  0x8(%ebp)
8010201b:	ff d0                	call   *%eax
8010201d:	83 c4 10             	add    $0x10,%esp
80102020:	e9 17 01 00 00       	jmp    8010213c <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102025:	8b 45 08             	mov    0x8(%ebp),%eax
80102028:	8b 40 18             	mov    0x18(%eax),%eax
8010202b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010202e:	72 0d                	jb     8010203d <writei+0x87>
80102030:	8b 55 10             	mov    0x10(%ebp),%edx
80102033:	8b 45 14             	mov    0x14(%ebp),%eax
80102036:	01 d0                	add    %edx,%eax
80102038:	3b 45 10             	cmp    0x10(%ebp),%eax
8010203b:	73 0a                	jae    80102047 <writei+0x91>
    return -1;
8010203d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102042:	e9 f5 00 00 00       	jmp    8010213c <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
80102047:	8b 55 10             	mov    0x10(%ebp),%edx
8010204a:	8b 45 14             	mov    0x14(%ebp),%eax
8010204d:	01 d0                	add    %edx,%eax
8010204f:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102054:	76 0a                	jbe    80102060 <writei+0xaa>
    return -1;
80102056:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010205b:	e9 dc 00 00 00       	jmp    8010213c <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102060:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102067:	e9 99 00 00 00       	jmp    80102105 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010206c:	8b 45 10             	mov    0x10(%ebp),%eax
8010206f:	c1 e8 09             	shr    $0x9,%eax
80102072:	83 ec 08             	sub    $0x8,%esp
80102075:	50                   	push   %eax
80102076:	ff 75 08             	pushl  0x8(%ebp)
80102079:	e8 58 fb ff ff       	call   80101bd6 <bmap>
8010207e:	83 c4 10             	add    $0x10,%esp
80102081:	89 c2                	mov    %eax,%edx
80102083:	8b 45 08             	mov    0x8(%ebp),%eax
80102086:	8b 00                	mov    (%eax),%eax
80102088:	83 ec 08             	sub    $0x8,%esp
8010208b:	52                   	push   %edx
8010208c:	50                   	push   %eax
8010208d:	e8 24 e1 ff ff       	call   801001b6 <bread>
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102098:	8b 45 10             	mov    0x10(%ebp),%eax
8010209b:	25 ff 01 00 00       	and    $0x1ff,%eax
801020a0:	ba 00 02 00 00       	mov    $0x200,%edx
801020a5:	29 c2                	sub    %eax,%edx
801020a7:	8b 45 14             	mov    0x14(%ebp),%eax
801020aa:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020ad:	39 c2                	cmp    %eax,%edx
801020af:	0f 46 c2             	cmovbe %edx,%eax
801020b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801020b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020b8:	8d 50 18             	lea    0x18(%eax),%edx
801020bb:	8b 45 10             	mov    0x10(%ebp),%eax
801020be:	25 ff 01 00 00       	and    $0x1ff,%eax
801020c3:	01 d0                	add    %edx,%eax
801020c5:	83 ec 04             	sub    $0x4,%esp
801020c8:	ff 75 ec             	pushl  -0x14(%ebp)
801020cb:	ff 75 0c             	pushl  0xc(%ebp)
801020ce:	50                   	push   %eax
801020cf:	e8 14 2e 00 00       	call   80104ee8 <memmove>
801020d4:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801020d7:	83 ec 0c             	sub    $0xc,%esp
801020da:	ff 75 f0             	pushl  -0x10(%ebp)
801020dd:	e8 51 12 00 00       	call   80103333 <log_write>
801020e2:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020e5:	83 ec 0c             	sub    $0xc,%esp
801020e8:	ff 75 f0             	pushl  -0x10(%ebp)
801020eb:	e8 3e e1 ff ff       	call   8010022e <brelse>
801020f0:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020f6:	01 45 f4             	add    %eax,-0xc(%ebp)
801020f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020fc:	01 45 10             	add    %eax,0x10(%ebp)
801020ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102102:	01 45 0c             	add    %eax,0xc(%ebp)
80102105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102108:	3b 45 14             	cmp    0x14(%ebp),%eax
8010210b:	0f 82 5b ff ff ff    	jb     8010206c <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102111:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102115:	74 22                	je     80102139 <writei+0x183>
80102117:	8b 45 08             	mov    0x8(%ebp),%eax
8010211a:	8b 40 18             	mov    0x18(%eax),%eax
8010211d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102120:	73 17                	jae    80102139 <writei+0x183>
    ip->size = off;
80102122:	8b 45 08             	mov    0x8(%ebp),%eax
80102125:	8b 55 10             	mov    0x10(%ebp),%edx
80102128:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010212b:	83 ec 0c             	sub    $0xc,%esp
8010212e:	ff 75 08             	pushl  0x8(%ebp)
80102131:	e8 ed f5 ff ff       	call   80101723 <iupdate>
80102136:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102139:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010213c:	c9                   	leave  
8010213d:	c3                   	ret    

8010213e <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010213e:	55                   	push   %ebp
8010213f:	89 e5                	mov    %esp,%ebp
80102141:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102144:	83 ec 04             	sub    $0x4,%esp
80102147:	6a 0e                	push   $0xe
80102149:	ff 75 0c             	pushl  0xc(%ebp)
8010214c:	ff 75 08             	pushl  0x8(%ebp)
8010214f:	e8 2a 2e 00 00       	call   80104f7e <strncmp>
80102154:	83 c4 10             	add    $0x10,%esp
}
80102157:	c9                   	leave  
80102158:	c3                   	ret    

80102159 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102159:	55                   	push   %ebp
8010215a:	89 e5                	mov    %esp,%ebp
8010215c:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010215f:	8b 45 08             	mov    0x8(%ebp),%eax
80102162:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102166:	66 83 f8 01          	cmp    $0x1,%ax
8010216a:	74 0d                	je     80102179 <dirlookup+0x20>
    panic("dirlookup not DIR");
8010216c:	83 ec 0c             	sub    $0xc,%esp
8010216f:	68 a5 82 10 80       	push   $0x801082a5
80102174:	e8 ed e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102179:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102180:	eb 7b                	jmp    801021fd <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102182:	6a 10                	push   $0x10
80102184:	ff 75 f4             	pushl  -0xc(%ebp)
80102187:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010218a:	50                   	push   %eax
8010218b:	ff 75 08             	pushl  0x8(%ebp)
8010218e:	e8 cc fc ff ff       	call   80101e5f <readi>
80102193:	83 c4 10             	add    $0x10,%esp
80102196:	83 f8 10             	cmp    $0x10,%eax
80102199:	74 0d                	je     801021a8 <dirlookup+0x4f>
      panic("dirlink read");
8010219b:	83 ec 0c             	sub    $0xc,%esp
8010219e:	68 b7 82 10 80       	push   $0x801082b7
801021a3:	e8 be e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801021a8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021ac:	66 85 c0             	test   %ax,%ax
801021af:	74 47                	je     801021f8 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801021b1:	83 ec 08             	sub    $0x8,%esp
801021b4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021b7:	83 c0 02             	add    $0x2,%eax
801021ba:	50                   	push   %eax
801021bb:	ff 75 0c             	pushl  0xc(%ebp)
801021be:	e8 7b ff ff ff       	call   8010213e <namecmp>
801021c3:	83 c4 10             	add    $0x10,%esp
801021c6:	85 c0                	test   %eax,%eax
801021c8:	75 2f                	jne    801021f9 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801021ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801021ce:	74 08                	je     801021d8 <dirlookup+0x7f>
        *poff = off;
801021d0:	8b 45 10             	mov    0x10(%ebp),%eax
801021d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021d6:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801021d8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021dc:	0f b7 c0             	movzwl %ax,%eax
801021df:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801021e2:	8b 45 08             	mov    0x8(%ebp),%eax
801021e5:	8b 00                	mov    (%eax),%eax
801021e7:	83 ec 08             	sub    $0x8,%esp
801021ea:	ff 75 f0             	pushl  -0x10(%ebp)
801021ed:	50                   	push   %eax
801021ee:	e8 eb f5 ff ff       	call   801017de <iget>
801021f3:	83 c4 10             	add    $0x10,%esp
801021f6:	eb 19                	jmp    80102211 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
801021f8:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801021f9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801021fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102200:	8b 40 18             	mov    0x18(%eax),%eax
80102203:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102206:	0f 87 76 ff ff ff    	ja     80102182 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010220c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102211:	c9                   	leave  
80102212:	c3                   	ret    

80102213 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102213:	55                   	push   %ebp
80102214:	89 e5                	mov    %esp,%ebp
80102216:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102219:	83 ec 04             	sub    $0x4,%esp
8010221c:	6a 00                	push   $0x0
8010221e:	ff 75 0c             	pushl  0xc(%ebp)
80102221:	ff 75 08             	pushl  0x8(%ebp)
80102224:	e8 30 ff ff ff       	call   80102159 <dirlookup>
80102229:	83 c4 10             	add    $0x10,%esp
8010222c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010222f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102233:	74 18                	je     8010224d <dirlink+0x3a>
    iput(ip);
80102235:	83 ec 0c             	sub    $0xc,%esp
80102238:	ff 75 f0             	pushl  -0x10(%ebp)
8010223b:	e8 81 f8 ff ff       	call   80101ac1 <iput>
80102240:	83 c4 10             	add    $0x10,%esp
    return -1;
80102243:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102248:	e9 9c 00 00 00       	jmp    801022e9 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010224d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102254:	eb 39                	jmp    8010228f <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102256:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102259:	6a 10                	push   $0x10
8010225b:	50                   	push   %eax
8010225c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010225f:	50                   	push   %eax
80102260:	ff 75 08             	pushl  0x8(%ebp)
80102263:	e8 f7 fb ff ff       	call   80101e5f <readi>
80102268:	83 c4 10             	add    $0x10,%esp
8010226b:	83 f8 10             	cmp    $0x10,%eax
8010226e:	74 0d                	je     8010227d <dirlink+0x6a>
      panic("dirlink read");
80102270:	83 ec 0c             	sub    $0xc,%esp
80102273:	68 b7 82 10 80       	push   $0x801082b7
80102278:	e8 e9 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
8010227d:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102281:	66 85 c0             	test   %ax,%ax
80102284:	74 18                	je     8010229e <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102289:	83 c0 10             	add    $0x10,%eax
8010228c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010228f:	8b 45 08             	mov    0x8(%ebp),%eax
80102292:	8b 50 18             	mov    0x18(%eax),%edx
80102295:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102298:	39 c2                	cmp    %eax,%edx
8010229a:	77 ba                	ja     80102256 <dirlink+0x43>
8010229c:	eb 01                	jmp    8010229f <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
8010229e:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010229f:	83 ec 04             	sub    $0x4,%esp
801022a2:	6a 0e                	push   $0xe
801022a4:	ff 75 0c             	pushl  0xc(%ebp)
801022a7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022aa:	83 c0 02             	add    $0x2,%eax
801022ad:	50                   	push   %eax
801022ae:	e8 21 2d 00 00       	call   80104fd4 <strncpy>
801022b3:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801022b6:	8b 45 10             	mov    0x10(%ebp),%eax
801022b9:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022c0:	6a 10                	push   $0x10
801022c2:	50                   	push   %eax
801022c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022c6:	50                   	push   %eax
801022c7:	ff 75 08             	pushl  0x8(%ebp)
801022ca:	e8 e7 fc ff ff       	call   80101fb6 <writei>
801022cf:	83 c4 10             	add    $0x10,%esp
801022d2:	83 f8 10             	cmp    $0x10,%eax
801022d5:	74 0d                	je     801022e4 <dirlink+0xd1>
    panic("dirlink");
801022d7:	83 ec 0c             	sub    $0xc,%esp
801022da:	68 c4 82 10 80       	push   $0x801082c4
801022df:	e8 82 e2 ff ff       	call   80100566 <panic>
  
  return 0;
801022e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022e9:	c9                   	leave  
801022ea:	c3                   	ret    

801022eb <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801022eb:	55                   	push   %ebp
801022ec:	89 e5                	mov    %esp,%ebp
801022ee:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801022f1:	eb 04                	jmp    801022f7 <skipelem+0xc>
    path++;
801022f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801022f7:	8b 45 08             	mov    0x8(%ebp),%eax
801022fa:	0f b6 00             	movzbl (%eax),%eax
801022fd:	3c 2f                	cmp    $0x2f,%al
801022ff:	74 f2                	je     801022f3 <skipelem+0x8>
    path++;
  if(*path == 0)
80102301:	8b 45 08             	mov    0x8(%ebp),%eax
80102304:	0f b6 00             	movzbl (%eax),%eax
80102307:	84 c0                	test   %al,%al
80102309:	75 07                	jne    80102312 <skipelem+0x27>
    return 0;
8010230b:	b8 00 00 00 00       	mov    $0x0,%eax
80102310:	eb 7b                	jmp    8010238d <skipelem+0xa2>
  s = path;
80102312:	8b 45 08             	mov    0x8(%ebp),%eax
80102315:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102318:	eb 04                	jmp    8010231e <skipelem+0x33>
    path++;
8010231a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010231e:	8b 45 08             	mov    0x8(%ebp),%eax
80102321:	0f b6 00             	movzbl (%eax),%eax
80102324:	3c 2f                	cmp    $0x2f,%al
80102326:	74 0a                	je     80102332 <skipelem+0x47>
80102328:	8b 45 08             	mov    0x8(%ebp),%eax
8010232b:	0f b6 00             	movzbl (%eax),%eax
8010232e:	84 c0                	test   %al,%al
80102330:	75 e8                	jne    8010231a <skipelem+0x2f>
    path++;
  len = path - s;
80102332:	8b 55 08             	mov    0x8(%ebp),%edx
80102335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102338:	29 c2                	sub    %eax,%edx
8010233a:	89 d0                	mov    %edx,%eax
8010233c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010233f:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102343:	7e 15                	jle    8010235a <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102345:	83 ec 04             	sub    $0x4,%esp
80102348:	6a 0e                	push   $0xe
8010234a:	ff 75 f4             	pushl  -0xc(%ebp)
8010234d:	ff 75 0c             	pushl  0xc(%ebp)
80102350:	e8 93 2b 00 00       	call   80104ee8 <memmove>
80102355:	83 c4 10             	add    $0x10,%esp
80102358:	eb 26                	jmp    80102380 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010235a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010235d:	83 ec 04             	sub    $0x4,%esp
80102360:	50                   	push   %eax
80102361:	ff 75 f4             	pushl  -0xc(%ebp)
80102364:	ff 75 0c             	pushl  0xc(%ebp)
80102367:	e8 7c 2b 00 00       	call   80104ee8 <memmove>
8010236c:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010236f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102372:	8b 45 0c             	mov    0xc(%ebp),%eax
80102375:	01 d0                	add    %edx,%eax
80102377:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010237a:	eb 04                	jmp    80102380 <skipelem+0x95>
    path++;
8010237c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102380:	8b 45 08             	mov    0x8(%ebp),%eax
80102383:	0f b6 00             	movzbl (%eax),%eax
80102386:	3c 2f                	cmp    $0x2f,%al
80102388:	74 f2                	je     8010237c <skipelem+0x91>
    path++;
  return path;
8010238a:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010238d:	c9                   	leave  
8010238e:	c3                   	ret    

8010238f <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010238f:	55                   	push   %ebp
80102390:	89 e5                	mov    %esp,%ebp
80102392:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102395:	8b 45 08             	mov    0x8(%ebp),%eax
80102398:	0f b6 00             	movzbl (%eax),%eax
8010239b:	3c 2f                	cmp    $0x2f,%al
8010239d:	75 17                	jne    801023b6 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010239f:	83 ec 08             	sub    $0x8,%esp
801023a2:	6a 01                	push   $0x1
801023a4:	6a 01                	push   $0x1
801023a6:	e8 33 f4 ff ff       	call   801017de <iget>
801023ab:	83 c4 10             	add    $0x10,%esp
801023ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023b1:	e9 bb 00 00 00       	jmp    80102471 <namex+0xe2>
  else
    ip = idup(proc->cwd);
801023b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801023bc:	8b 40 68             	mov    0x68(%eax),%eax
801023bf:	83 ec 0c             	sub    $0xc,%esp
801023c2:	50                   	push   %eax
801023c3:	e8 f5 f4 ff ff       	call   801018bd <idup>
801023c8:	83 c4 10             	add    $0x10,%esp
801023cb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801023ce:	e9 9e 00 00 00       	jmp    80102471 <namex+0xe2>
    ilock(ip);
801023d3:	83 ec 0c             	sub    $0xc,%esp
801023d6:	ff 75 f4             	pushl  -0xc(%ebp)
801023d9:	e8 19 f5 ff ff       	call   801018f7 <ilock>
801023de:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801023e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023e8:	66 83 f8 01          	cmp    $0x1,%ax
801023ec:	74 18                	je     80102406 <namex+0x77>
      iunlockput(ip);
801023ee:	83 ec 0c             	sub    $0xc,%esp
801023f1:	ff 75 f4             	pushl  -0xc(%ebp)
801023f4:	e8 b8 f7 ff ff       	call   80101bb1 <iunlockput>
801023f9:	83 c4 10             	add    $0x10,%esp
      return 0;
801023fc:	b8 00 00 00 00       	mov    $0x0,%eax
80102401:	e9 a7 00 00 00       	jmp    801024ad <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102406:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010240a:	74 20                	je     8010242c <namex+0x9d>
8010240c:	8b 45 08             	mov    0x8(%ebp),%eax
8010240f:	0f b6 00             	movzbl (%eax),%eax
80102412:	84 c0                	test   %al,%al
80102414:	75 16                	jne    8010242c <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102416:	83 ec 0c             	sub    $0xc,%esp
80102419:	ff 75 f4             	pushl  -0xc(%ebp)
8010241c:	e8 2e f6 ff ff       	call   80101a4f <iunlock>
80102421:	83 c4 10             	add    $0x10,%esp
      return ip;
80102424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102427:	e9 81 00 00 00       	jmp    801024ad <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010242c:	83 ec 04             	sub    $0x4,%esp
8010242f:	6a 00                	push   $0x0
80102431:	ff 75 10             	pushl  0x10(%ebp)
80102434:	ff 75 f4             	pushl  -0xc(%ebp)
80102437:	e8 1d fd ff ff       	call   80102159 <dirlookup>
8010243c:	83 c4 10             	add    $0x10,%esp
8010243f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102442:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102446:	75 15                	jne    8010245d <namex+0xce>
      iunlockput(ip);
80102448:	83 ec 0c             	sub    $0xc,%esp
8010244b:	ff 75 f4             	pushl  -0xc(%ebp)
8010244e:	e8 5e f7 ff ff       	call   80101bb1 <iunlockput>
80102453:	83 c4 10             	add    $0x10,%esp
      return 0;
80102456:	b8 00 00 00 00       	mov    $0x0,%eax
8010245b:	eb 50                	jmp    801024ad <namex+0x11e>
    }
    iunlockput(ip);
8010245d:	83 ec 0c             	sub    $0xc,%esp
80102460:	ff 75 f4             	pushl  -0xc(%ebp)
80102463:	e8 49 f7 ff ff       	call   80101bb1 <iunlockput>
80102468:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010246b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010246e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102471:	83 ec 08             	sub    $0x8,%esp
80102474:	ff 75 10             	pushl  0x10(%ebp)
80102477:	ff 75 08             	pushl  0x8(%ebp)
8010247a:	e8 6c fe ff ff       	call   801022eb <skipelem>
8010247f:	83 c4 10             	add    $0x10,%esp
80102482:	89 45 08             	mov    %eax,0x8(%ebp)
80102485:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102489:	0f 85 44 ff ff ff    	jne    801023d3 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
8010248f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102493:	74 15                	je     801024aa <namex+0x11b>
    iput(ip);
80102495:	83 ec 0c             	sub    $0xc,%esp
80102498:	ff 75 f4             	pushl  -0xc(%ebp)
8010249b:	e8 21 f6 ff ff       	call   80101ac1 <iput>
801024a0:	83 c4 10             	add    $0x10,%esp
    return 0;
801024a3:	b8 00 00 00 00       	mov    $0x0,%eax
801024a8:	eb 03                	jmp    801024ad <namex+0x11e>
  }
  return ip;
801024aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801024ad:	c9                   	leave  
801024ae:	c3                   	ret    

801024af <namei>:

struct inode*
namei(char *path)
{
801024af:	55                   	push   %ebp
801024b0:	89 e5                	mov    %esp,%ebp
801024b2:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801024b5:	83 ec 04             	sub    $0x4,%esp
801024b8:	8d 45 ea             	lea    -0x16(%ebp),%eax
801024bb:	50                   	push   %eax
801024bc:	6a 00                	push   $0x0
801024be:	ff 75 08             	pushl  0x8(%ebp)
801024c1:	e8 c9 fe ff ff       	call   8010238f <namex>
801024c6:	83 c4 10             	add    $0x10,%esp
}
801024c9:	c9                   	leave  
801024ca:	c3                   	ret    

801024cb <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801024cb:	55                   	push   %ebp
801024cc:	89 e5                	mov    %esp,%ebp
801024ce:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801024d1:	83 ec 04             	sub    $0x4,%esp
801024d4:	ff 75 0c             	pushl  0xc(%ebp)
801024d7:	6a 01                	push   $0x1
801024d9:	ff 75 08             	pushl  0x8(%ebp)
801024dc:	e8 ae fe ff ff       	call   8010238f <namex>
801024e1:	83 c4 10             	add    $0x10,%esp
}
801024e4:	c9                   	leave  
801024e5:	c3                   	ret    

801024e6 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801024e6:	55                   	push   %ebp
801024e7:	89 e5                	mov    %esp,%ebp
801024e9:	83 ec 14             	sub    $0x14,%esp
801024ec:	8b 45 08             	mov    0x8(%ebp),%eax
801024ef:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024f3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801024f7:	89 c2                	mov    %eax,%edx
801024f9:	ec                   	in     (%dx),%al
801024fa:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801024fd:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102501:	c9                   	leave  
80102502:	c3                   	ret    

80102503 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102503:	55                   	push   %ebp
80102504:	89 e5                	mov    %esp,%ebp
80102506:	57                   	push   %edi
80102507:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102508:	8b 55 08             	mov    0x8(%ebp),%edx
8010250b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010250e:	8b 45 10             	mov    0x10(%ebp),%eax
80102511:	89 cb                	mov    %ecx,%ebx
80102513:	89 df                	mov    %ebx,%edi
80102515:	89 c1                	mov    %eax,%ecx
80102517:	fc                   	cld    
80102518:	f3 6d                	rep insl (%dx),%es:(%edi)
8010251a:	89 c8                	mov    %ecx,%eax
8010251c:	89 fb                	mov    %edi,%ebx
8010251e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102521:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102524:	90                   	nop
80102525:	5b                   	pop    %ebx
80102526:	5f                   	pop    %edi
80102527:	5d                   	pop    %ebp
80102528:	c3                   	ret    

80102529 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102529:	55                   	push   %ebp
8010252a:	89 e5                	mov    %esp,%ebp
8010252c:	83 ec 08             	sub    $0x8,%esp
8010252f:	8b 55 08             	mov    0x8(%ebp),%edx
80102532:	8b 45 0c             	mov    0xc(%ebp),%eax
80102535:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102539:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010253c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102540:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102544:	ee                   	out    %al,(%dx)
}
80102545:	90                   	nop
80102546:	c9                   	leave  
80102547:	c3                   	ret    

80102548 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102548:	55                   	push   %ebp
80102549:	89 e5                	mov    %esp,%ebp
8010254b:	56                   	push   %esi
8010254c:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010254d:	8b 55 08             	mov    0x8(%ebp),%edx
80102550:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102553:	8b 45 10             	mov    0x10(%ebp),%eax
80102556:	89 cb                	mov    %ecx,%ebx
80102558:	89 de                	mov    %ebx,%esi
8010255a:	89 c1                	mov    %eax,%ecx
8010255c:	fc                   	cld    
8010255d:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010255f:	89 c8                	mov    %ecx,%eax
80102561:	89 f3                	mov    %esi,%ebx
80102563:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102566:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102569:	90                   	nop
8010256a:	5b                   	pop    %ebx
8010256b:	5e                   	pop    %esi
8010256c:	5d                   	pop    %ebp
8010256d:	c3                   	ret    

8010256e <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010256e:	55                   	push   %ebp
8010256f:	89 e5                	mov    %esp,%ebp
80102571:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102574:	90                   	nop
80102575:	68 f7 01 00 00       	push   $0x1f7
8010257a:	e8 67 ff ff ff       	call   801024e6 <inb>
8010257f:	83 c4 04             	add    $0x4,%esp
80102582:	0f b6 c0             	movzbl %al,%eax
80102585:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102588:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010258b:	25 c0 00 00 00       	and    $0xc0,%eax
80102590:	83 f8 40             	cmp    $0x40,%eax
80102593:	75 e0                	jne    80102575 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102595:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102599:	74 11                	je     801025ac <idewait+0x3e>
8010259b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010259e:	83 e0 21             	and    $0x21,%eax
801025a1:	85 c0                	test   %eax,%eax
801025a3:	74 07                	je     801025ac <idewait+0x3e>
    return -1;
801025a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025aa:	eb 05                	jmp    801025b1 <idewait+0x43>
  return 0;
801025ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801025b1:	c9                   	leave  
801025b2:	c3                   	ret    

801025b3 <ideinit>:

void
ideinit(void)
{
801025b3:	55                   	push   %ebp
801025b4:	89 e5                	mov    %esp,%ebp
801025b6:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801025b9:	83 ec 08             	sub    $0x8,%esp
801025bc:	68 cc 82 10 80       	push   $0x801082cc
801025c1:	68 20 b6 10 80       	push   $0x8010b620
801025c6:	e8 d9 25 00 00       	call   80104ba4 <initlock>
801025cb:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801025ce:	83 ec 0c             	sub    $0xc,%esp
801025d1:	6a 0e                	push   $0xe
801025d3:	e8 59 15 00 00       	call   80103b31 <picenable>
801025d8:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801025db:	a1 40 ff 10 80       	mov    0x8010ff40,%eax
801025e0:	83 e8 01             	sub    $0x1,%eax
801025e3:	83 ec 08             	sub    $0x8,%esp
801025e6:	50                   	push   %eax
801025e7:	6a 0e                	push   $0xe
801025e9:	e8 37 04 00 00       	call   80102a25 <ioapicenable>
801025ee:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801025f1:	83 ec 0c             	sub    $0xc,%esp
801025f4:	6a 00                	push   $0x0
801025f6:	e8 73 ff ff ff       	call   8010256e <idewait>
801025fb:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801025fe:	83 ec 08             	sub    $0x8,%esp
80102601:	68 f0 00 00 00       	push   $0xf0
80102606:	68 f6 01 00 00       	push   $0x1f6
8010260b:	e8 19 ff ff ff       	call   80102529 <outb>
80102610:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102613:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010261a:	eb 24                	jmp    80102640 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
8010261c:	83 ec 0c             	sub    $0xc,%esp
8010261f:	68 f7 01 00 00       	push   $0x1f7
80102624:	e8 bd fe ff ff       	call   801024e6 <inb>
80102629:	83 c4 10             	add    $0x10,%esp
8010262c:	84 c0                	test   %al,%al
8010262e:	74 0c                	je     8010263c <ideinit+0x89>
      havedisk1 = 1;
80102630:	c7 05 58 b6 10 80 01 	movl   $0x1,0x8010b658
80102637:	00 00 00 
      break;
8010263a:	eb 0d                	jmp    80102649 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
8010263c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102640:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102647:	7e d3                	jle    8010261c <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102649:	83 ec 08             	sub    $0x8,%esp
8010264c:	68 e0 00 00 00       	push   $0xe0
80102651:	68 f6 01 00 00       	push   $0x1f6
80102656:	e8 ce fe ff ff       	call   80102529 <outb>
8010265b:	83 c4 10             	add    $0x10,%esp
}
8010265e:	90                   	nop
8010265f:	c9                   	leave  
80102660:	c3                   	ret    

80102661 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102661:	55                   	push   %ebp
80102662:	89 e5                	mov    %esp,%ebp
80102664:	83 ec 08             	sub    $0x8,%esp
  if(b == 0)
80102667:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010266b:	75 0d                	jne    8010267a <idestart+0x19>
    panic("idestart");
8010266d:	83 ec 0c             	sub    $0xc,%esp
80102670:	68 d0 82 10 80       	push   $0x801082d0
80102675:	e8 ec de ff ff       	call   80100566 <panic>

  idewait(0);
8010267a:	83 ec 0c             	sub    $0xc,%esp
8010267d:	6a 00                	push   $0x0
8010267f:	e8 ea fe ff ff       	call   8010256e <idewait>
80102684:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102687:	83 ec 08             	sub    $0x8,%esp
8010268a:	6a 00                	push   $0x0
8010268c:	68 f6 03 00 00       	push   $0x3f6
80102691:	e8 93 fe ff ff       	call   80102529 <outb>
80102696:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, 1);  // number of sectors
80102699:	83 ec 08             	sub    $0x8,%esp
8010269c:	6a 01                	push   $0x1
8010269e:	68 f2 01 00 00       	push   $0x1f2
801026a3:	e8 81 fe ff ff       	call   80102529 <outb>
801026a8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, b->sector & 0xff);
801026ab:	8b 45 08             	mov    0x8(%ebp),%eax
801026ae:	8b 40 08             	mov    0x8(%eax),%eax
801026b1:	0f b6 c0             	movzbl %al,%eax
801026b4:	83 ec 08             	sub    $0x8,%esp
801026b7:	50                   	push   %eax
801026b8:	68 f3 01 00 00       	push   $0x1f3
801026bd:	e8 67 fe ff ff       	call   80102529 <outb>
801026c2:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (b->sector >> 8) & 0xff);
801026c5:	8b 45 08             	mov    0x8(%ebp),%eax
801026c8:	8b 40 08             	mov    0x8(%eax),%eax
801026cb:	c1 e8 08             	shr    $0x8,%eax
801026ce:	0f b6 c0             	movzbl %al,%eax
801026d1:	83 ec 08             	sub    $0x8,%esp
801026d4:	50                   	push   %eax
801026d5:	68 f4 01 00 00       	push   $0x1f4
801026da:	e8 4a fe ff ff       	call   80102529 <outb>
801026df:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (b->sector >> 16) & 0xff);
801026e2:	8b 45 08             	mov    0x8(%ebp),%eax
801026e5:	8b 40 08             	mov    0x8(%eax),%eax
801026e8:	c1 e8 10             	shr    $0x10,%eax
801026eb:	0f b6 c0             	movzbl %al,%eax
801026ee:	83 ec 08             	sub    $0x8,%esp
801026f1:	50                   	push   %eax
801026f2:	68 f5 01 00 00       	push   $0x1f5
801026f7:	e8 2d fe ff ff       	call   80102529 <outb>
801026fc:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
801026ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102702:	8b 40 04             	mov    0x4(%eax),%eax
80102705:	83 e0 01             	and    $0x1,%eax
80102708:	c1 e0 04             	shl    $0x4,%eax
8010270b:	89 c2                	mov    %eax,%edx
8010270d:	8b 45 08             	mov    0x8(%ebp),%eax
80102710:	8b 40 08             	mov    0x8(%eax),%eax
80102713:	c1 e8 18             	shr    $0x18,%eax
80102716:	83 e0 0f             	and    $0xf,%eax
80102719:	09 d0                	or     %edx,%eax
8010271b:	83 c8 e0             	or     $0xffffffe0,%eax
8010271e:	0f b6 c0             	movzbl %al,%eax
80102721:	83 ec 08             	sub    $0x8,%esp
80102724:	50                   	push   %eax
80102725:	68 f6 01 00 00       	push   $0x1f6
8010272a:	e8 fa fd ff ff       	call   80102529 <outb>
8010272f:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102732:	8b 45 08             	mov    0x8(%ebp),%eax
80102735:	8b 00                	mov    (%eax),%eax
80102737:	83 e0 04             	and    $0x4,%eax
8010273a:	85 c0                	test   %eax,%eax
8010273c:	74 30                	je     8010276e <idestart+0x10d>
    outb(0x1f7, IDE_CMD_WRITE);
8010273e:	83 ec 08             	sub    $0x8,%esp
80102741:	6a 30                	push   $0x30
80102743:	68 f7 01 00 00       	push   $0x1f7
80102748:	e8 dc fd ff ff       	call   80102529 <outb>
8010274d:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, 512/4);
80102750:	8b 45 08             	mov    0x8(%ebp),%eax
80102753:	83 c0 18             	add    $0x18,%eax
80102756:	83 ec 04             	sub    $0x4,%esp
80102759:	68 80 00 00 00       	push   $0x80
8010275e:	50                   	push   %eax
8010275f:	68 f0 01 00 00       	push   $0x1f0
80102764:	e8 df fd ff ff       	call   80102548 <outsl>
80102769:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
8010276c:	eb 12                	jmp    80102780 <idestart+0x11f>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, 512/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010276e:	83 ec 08             	sub    $0x8,%esp
80102771:	6a 20                	push   $0x20
80102773:	68 f7 01 00 00       	push   $0x1f7
80102778:	e8 ac fd ff ff       	call   80102529 <outb>
8010277d:	83 c4 10             	add    $0x10,%esp
  }
}
80102780:	90                   	nop
80102781:	c9                   	leave  
80102782:	c3                   	ret    

80102783 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102783:	55                   	push   %ebp
80102784:	89 e5                	mov    %esp,%ebp
80102786:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102789:	83 ec 0c             	sub    $0xc,%esp
8010278c:	68 20 b6 10 80       	push   $0x8010b620
80102791:	e8 30 24 00 00       	call   80104bc6 <acquire>
80102796:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102799:	a1 54 b6 10 80       	mov    0x8010b654,%eax
8010279e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027a5:	75 15                	jne    801027bc <ideintr+0x39>
    release(&idelock);
801027a7:	83 ec 0c             	sub    $0xc,%esp
801027aa:	68 20 b6 10 80       	push   $0x8010b620
801027af:	e8 79 24 00 00       	call   80104c2d <release>
801027b4:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
801027b7:	e9 9a 00 00 00       	jmp    80102856 <ideintr+0xd3>
  }
  idequeue = b->qnext;
801027bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027bf:	8b 40 14             	mov    0x14(%eax),%eax
801027c2:	a3 54 b6 10 80       	mov    %eax,0x8010b654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801027c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ca:	8b 00                	mov    (%eax),%eax
801027cc:	83 e0 04             	and    $0x4,%eax
801027cf:	85 c0                	test   %eax,%eax
801027d1:	75 2d                	jne    80102800 <ideintr+0x7d>
801027d3:	83 ec 0c             	sub    $0xc,%esp
801027d6:	6a 01                	push   $0x1
801027d8:	e8 91 fd ff ff       	call   8010256e <idewait>
801027dd:	83 c4 10             	add    $0x10,%esp
801027e0:	85 c0                	test   %eax,%eax
801027e2:	78 1c                	js     80102800 <ideintr+0x7d>
    insl(0x1f0, b->data, 512/4);
801027e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e7:	83 c0 18             	add    $0x18,%eax
801027ea:	83 ec 04             	sub    $0x4,%esp
801027ed:	68 80 00 00 00       	push   $0x80
801027f2:	50                   	push   %eax
801027f3:	68 f0 01 00 00       	push   $0x1f0
801027f8:	e8 06 fd ff ff       	call   80102503 <insl>
801027fd:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102803:	8b 00                	mov    (%eax),%eax
80102805:	83 c8 02             	or     $0x2,%eax
80102808:	89 c2                	mov    %eax,%edx
8010280a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010280d:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010280f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102812:	8b 00                	mov    (%eax),%eax
80102814:	83 e0 fb             	and    $0xfffffffb,%eax
80102817:	89 c2                	mov    %eax,%edx
80102819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010281c:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010281e:	83 ec 0c             	sub    $0xc,%esp
80102821:	ff 75 f4             	pushl  -0xc(%ebp)
80102824:	e8 8f 21 00 00       	call   801049b8 <wakeup>
80102829:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010282c:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102831:	85 c0                	test   %eax,%eax
80102833:	74 11                	je     80102846 <ideintr+0xc3>
    idestart(idequeue);
80102835:	a1 54 b6 10 80       	mov    0x8010b654,%eax
8010283a:	83 ec 0c             	sub    $0xc,%esp
8010283d:	50                   	push   %eax
8010283e:	e8 1e fe ff ff       	call   80102661 <idestart>
80102843:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102846:	83 ec 0c             	sub    $0xc,%esp
80102849:	68 20 b6 10 80       	push   $0x8010b620
8010284e:	e8 da 23 00 00       	call   80104c2d <release>
80102853:	83 c4 10             	add    $0x10,%esp
}
80102856:	c9                   	leave  
80102857:	c3                   	ret    

80102858 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102858:	55                   	push   %ebp
80102859:	89 e5                	mov    %esp,%ebp
8010285b:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010285e:	8b 45 08             	mov    0x8(%ebp),%eax
80102861:	8b 00                	mov    (%eax),%eax
80102863:	83 e0 01             	and    $0x1,%eax
80102866:	85 c0                	test   %eax,%eax
80102868:	75 0d                	jne    80102877 <iderw+0x1f>
    panic("iderw: buf not busy");
8010286a:	83 ec 0c             	sub    $0xc,%esp
8010286d:	68 d9 82 10 80       	push   $0x801082d9
80102872:	e8 ef dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102877:	8b 45 08             	mov    0x8(%ebp),%eax
8010287a:	8b 00                	mov    (%eax),%eax
8010287c:	83 e0 06             	and    $0x6,%eax
8010287f:	83 f8 02             	cmp    $0x2,%eax
80102882:	75 0d                	jne    80102891 <iderw+0x39>
    panic("iderw: nothing to do");
80102884:	83 ec 0c             	sub    $0xc,%esp
80102887:	68 ed 82 10 80       	push   $0x801082ed
8010288c:	e8 d5 dc ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102891:	8b 45 08             	mov    0x8(%ebp),%eax
80102894:	8b 40 04             	mov    0x4(%eax),%eax
80102897:	85 c0                	test   %eax,%eax
80102899:	74 16                	je     801028b1 <iderw+0x59>
8010289b:	a1 58 b6 10 80       	mov    0x8010b658,%eax
801028a0:	85 c0                	test   %eax,%eax
801028a2:	75 0d                	jne    801028b1 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
801028a4:	83 ec 0c             	sub    $0xc,%esp
801028a7:	68 02 83 10 80       	push   $0x80108302
801028ac:	e8 b5 dc ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801028b1:	83 ec 0c             	sub    $0xc,%esp
801028b4:	68 20 b6 10 80       	push   $0x8010b620
801028b9:	e8 08 23 00 00       	call   80104bc6 <acquire>
801028be:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801028c1:	8b 45 08             	mov    0x8(%ebp),%eax
801028c4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801028cb:	c7 45 f4 54 b6 10 80 	movl   $0x8010b654,-0xc(%ebp)
801028d2:	eb 0b                	jmp    801028df <iderw+0x87>
801028d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d7:	8b 00                	mov    (%eax),%eax
801028d9:	83 c0 14             	add    $0x14,%eax
801028dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e2:	8b 00                	mov    (%eax),%eax
801028e4:	85 c0                	test   %eax,%eax
801028e6:	75 ec                	jne    801028d4 <iderw+0x7c>
    ;
  *pp = b;
801028e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028eb:	8b 55 08             	mov    0x8(%ebp),%edx
801028ee:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801028f0:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801028f5:	3b 45 08             	cmp    0x8(%ebp),%eax
801028f8:	75 23                	jne    8010291d <iderw+0xc5>
    idestart(b);
801028fa:	83 ec 0c             	sub    $0xc,%esp
801028fd:	ff 75 08             	pushl  0x8(%ebp)
80102900:	e8 5c fd ff ff       	call   80102661 <idestart>
80102905:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102908:	eb 13                	jmp    8010291d <iderw+0xc5>
    sleep(b, &idelock);
8010290a:	83 ec 08             	sub    $0x8,%esp
8010290d:	68 20 b6 10 80       	push   $0x8010b620
80102912:	ff 75 08             	pushl  0x8(%ebp)
80102915:	e8 b3 1f 00 00       	call   801048cd <sleep>
8010291a:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010291d:	8b 45 08             	mov    0x8(%ebp),%eax
80102920:	8b 00                	mov    (%eax),%eax
80102922:	83 e0 06             	and    $0x6,%eax
80102925:	83 f8 02             	cmp    $0x2,%eax
80102928:	75 e0                	jne    8010290a <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
8010292a:	83 ec 0c             	sub    $0xc,%esp
8010292d:	68 20 b6 10 80       	push   $0x8010b620
80102932:	e8 f6 22 00 00       	call   80104c2d <release>
80102937:	83 c4 10             	add    $0x10,%esp
}
8010293a:	90                   	nop
8010293b:	c9                   	leave  
8010293c:	c3                   	ret    

8010293d <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010293d:	55                   	push   %ebp
8010293e:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102940:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102945:	8b 55 08             	mov    0x8(%ebp),%edx
80102948:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010294a:	a1 54 f8 10 80       	mov    0x8010f854,%eax
8010294f:	8b 40 10             	mov    0x10(%eax),%eax
}
80102952:	5d                   	pop    %ebp
80102953:	c3                   	ret    

80102954 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102954:	55                   	push   %ebp
80102955:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102957:	a1 54 f8 10 80       	mov    0x8010f854,%eax
8010295c:	8b 55 08             	mov    0x8(%ebp),%edx
8010295f:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102961:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102966:	8b 55 0c             	mov    0xc(%ebp),%edx
80102969:	89 50 10             	mov    %edx,0x10(%eax)
}
8010296c:	90                   	nop
8010296d:	5d                   	pop    %ebp
8010296e:	c3                   	ret    

8010296f <ioapicinit>:

void
ioapicinit(void)
{
8010296f:	55                   	push   %ebp
80102970:	89 e5                	mov    %esp,%ebp
80102972:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102975:	a1 24 f9 10 80       	mov    0x8010f924,%eax
8010297a:	85 c0                	test   %eax,%eax
8010297c:	0f 84 a0 00 00 00    	je     80102a22 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102982:	c7 05 54 f8 10 80 00 	movl   $0xfec00000,0x8010f854
80102989:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010298c:	6a 01                	push   $0x1
8010298e:	e8 aa ff ff ff       	call   8010293d <ioapicread>
80102993:	83 c4 04             	add    $0x4,%esp
80102996:	c1 e8 10             	shr    $0x10,%eax
80102999:	25 ff 00 00 00       	and    $0xff,%eax
8010299e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801029a1:	6a 00                	push   $0x0
801029a3:	e8 95 ff ff ff       	call   8010293d <ioapicread>
801029a8:	83 c4 04             	add    $0x4,%esp
801029ab:	c1 e8 18             	shr    $0x18,%eax
801029ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801029b1:	0f b6 05 20 f9 10 80 	movzbl 0x8010f920,%eax
801029b8:	0f b6 c0             	movzbl %al,%eax
801029bb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801029be:	74 10                	je     801029d0 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801029c0:	83 ec 0c             	sub    $0xc,%esp
801029c3:	68 20 83 10 80       	push   $0x80108320
801029c8:	e8 f9 d9 ff ff       	call   801003c6 <cprintf>
801029cd:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029d7:	eb 3f                	jmp    80102a18 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801029d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029dc:	83 c0 20             	add    $0x20,%eax
801029df:	0d 00 00 01 00       	or     $0x10000,%eax
801029e4:	89 c2                	mov    %eax,%edx
801029e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e9:	83 c0 08             	add    $0x8,%eax
801029ec:	01 c0                	add    %eax,%eax
801029ee:	83 ec 08             	sub    $0x8,%esp
801029f1:	52                   	push   %edx
801029f2:	50                   	push   %eax
801029f3:	e8 5c ff ff ff       	call   80102954 <ioapicwrite>
801029f8:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801029fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029fe:	83 c0 08             	add    $0x8,%eax
80102a01:	01 c0                	add    %eax,%eax
80102a03:	83 c0 01             	add    $0x1,%eax
80102a06:	83 ec 08             	sub    $0x8,%esp
80102a09:	6a 00                	push   $0x0
80102a0b:	50                   	push   %eax
80102a0c:	e8 43 ff ff ff       	call   80102954 <ioapicwrite>
80102a11:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a14:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a1b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a1e:	7e b9                	jle    801029d9 <ioapicinit+0x6a>
80102a20:	eb 01                	jmp    80102a23 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102a22:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102a23:	c9                   	leave  
80102a24:	c3                   	ret    

80102a25 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a25:	55                   	push   %ebp
80102a26:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102a28:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102a2d:	85 c0                	test   %eax,%eax
80102a2f:	74 39                	je     80102a6a <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a31:	8b 45 08             	mov    0x8(%ebp),%eax
80102a34:	83 c0 20             	add    $0x20,%eax
80102a37:	89 c2                	mov    %eax,%edx
80102a39:	8b 45 08             	mov    0x8(%ebp),%eax
80102a3c:	83 c0 08             	add    $0x8,%eax
80102a3f:	01 c0                	add    %eax,%eax
80102a41:	52                   	push   %edx
80102a42:	50                   	push   %eax
80102a43:	e8 0c ff ff ff       	call   80102954 <ioapicwrite>
80102a48:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a4e:	c1 e0 18             	shl    $0x18,%eax
80102a51:	89 c2                	mov    %eax,%edx
80102a53:	8b 45 08             	mov    0x8(%ebp),%eax
80102a56:	83 c0 08             	add    $0x8,%eax
80102a59:	01 c0                	add    %eax,%eax
80102a5b:	83 c0 01             	add    $0x1,%eax
80102a5e:	52                   	push   %edx
80102a5f:	50                   	push   %eax
80102a60:	e8 ef fe ff ff       	call   80102954 <ioapicwrite>
80102a65:	83 c4 08             	add    $0x8,%esp
80102a68:	eb 01                	jmp    80102a6b <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102a6a:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102a6b:	c9                   	leave  
80102a6c:	c3                   	ret    

80102a6d <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102a6d:	55                   	push   %ebp
80102a6e:	89 e5                	mov    %esp,%ebp
80102a70:	8b 45 08             	mov    0x8(%ebp),%eax
80102a73:	05 00 00 00 80       	add    $0x80000000,%eax
80102a78:	5d                   	pop    %ebp
80102a79:	c3                   	ret    

80102a7a <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a7a:	55                   	push   %ebp
80102a7b:	89 e5                	mov    %esp,%ebp
80102a7d:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102a80:	83 ec 08             	sub    $0x8,%esp
80102a83:	68 52 83 10 80       	push   $0x80108352
80102a88:	68 60 f8 10 80       	push   $0x8010f860
80102a8d:	e8 12 21 00 00       	call   80104ba4 <initlock>
80102a92:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102a95:	c7 05 94 f8 10 80 00 	movl   $0x0,0x8010f894
80102a9c:	00 00 00 
  freerange(vstart, vend);
80102a9f:	83 ec 08             	sub    $0x8,%esp
80102aa2:	ff 75 0c             	pushl  0xc(%ebp)
80102aa5:	ff 75 08             	pushl  0x8(%ebp)
80102aa8:	e8 2a 00 00 00       	call   80102ad7 <freerange>
80102aad:	83 c4 10             	add    $0x10,%esp
}
80102ab0:	90                   	nop
80102ab1:	c9                   	leave  
80102ab2:	c3                   	ret    

80102ab3 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102ab3:	55                   	push   %ebp
80102ab4:	89 e5                	mov    %esp,%ebp
80102ab6:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102ab9:	83 ec 08             	sub    $0x8,%esp
80102abc:	ff 75 0c             	pushl  0xc(%ebp)
80102abf:	ff 75 08             	pushl  0x8(%ebp)
80102ac2:	e8 10 00 00 00       	call   80102ad7 <freerange>
80102ac7:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102aca:	c7 05 94 f8 10 80 01 	movl   $0x1,0x8010f894
80102ad1:	00 00 00 
}
80102ad4:	90                   	nop
80102ad5:	c9                   	leave  
80102ad6:	c3                   	ret    

80102ad7 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102ad7:	55                   	push   %ebp
80102ad8:	89 e5                	mov    %esp,%ebp
80102ada:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102add:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae0:	05 ff 0f 00 00       	add    $0xfff,%eax
80102ae5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102aea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102aed:	eb 15                	jmp    80102b04 <freerange+0x2d>
    kfree(p);
80102aef:	83 ec 0c             	sub    $0xc,%esp
80102af2:	ff 75 f4             	pushl  -0xc(%ebp)
80102af5:	e8 1a 00 00 00       	call   80102b14 <kfree>
80102afa:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102afd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b07:	05 00 10 00 00       	add    $0x1000,%eax
80102b0c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102b0f:	76 de                	jbe    80102aef <freerange+0x18>
    kfree(p);
}
80102b11:	90                   	nop
80102b12:	c9                   	leave  
80102b13:	c3                   	ret    

80102b14 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102b14:	55                   	push   %ebp
80102b15:	89 e5                	mov    %esp,%ebp
80102b17:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1d:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b22:	85 c0                	test   %eax,%eax
80102b24:	75 1b                	jne    80102b41 <kfree+0x2d>
80102b26:	81 7d 08 3c 27 11 80 	cmpl   $0x8011273c,0x8(%ebp)
80102b2d:	72 12                	jb     80102b41 <kfree+0x2d>
80102b2f:	ff 75 08             	pushl  0x8(%ebp)
80102b32:	e8 36 ff ff ff       	call   80102a6d <v2p>
80102b37:	83 c4 04             	add    $0x4,%esp
80102b3a:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b3f:	76 0d                	jbe    80102b4e <kfree+0x3a>
    panic("kfree");
80102b41:	83 ec 0c             	sub    $0xc,%esp
80102b44:	68 57 83 10 80       	push   $0x80108357
80102b49:	e8 18 da ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b4e:	83 ec 04             	sub    $0x4,%esp
80102b51:	68 00 10 00 00       	push   $0x1000
80102b56:	6a 01                	push   $0x1
80102b58:	ff 75 08             	pushl  0x8(%ebp)
80102b5b:	e8 c9 22 00 00       	call   80104e29 <memset>
80102b60:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102b63:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102b68:	85 c0                	test   %eax,%eax
80102b6a:	74 10                	je     80102b7c <kfree+0x68>
    acquire(&kmem.lock);
80102b6c:	83 ec 0c             	sub    $0xc,%esp
80102b6f:	68 60 f8 10 80       	push   $0x8010f860
80102b74:	e8 4d 20 00 00       	call   80104bc6 <acquire>
80102b79:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b82:	8b 15 98 f8 10 80    	mov    0x8010f898,%edx
80102b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8b:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b90:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102b95:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102b9a:	85 c0                	test   %eax,%eax
80102b9c:	74 10                	je     80102bae <kfree+0x9a>
    release(&kmem.lock);
80102b9e:	83 ec 0c             	sub    $0xc,%esp
80102ba1:	68 60 f8 10 80       	push   $0x8010f860
80102ba6:	e8 82 20 00 00       	call   80104c2d <release>
80102bab:	83 c4 10             	add    $0x10,%esp
}
80102bae:	90                   	nop
80102baf:	c9                   	leave  
80102bb0:	c3                   	ret    

80102bb1 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102bb1:	55                   	push   %ebp
80102bb2:	89 e5                	mov    %esp,%ebp
80102bb4:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102bb7:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102bbc:	85 c0                	test   %eax,%eax
80102bbe:	74 10                	je     80102bd0 <kalloc+0x1f>
    acquire(&kmem.lock);
80102bc0:	83 ec 0c             	sub    $0xc,%esp
80102bc3:	68 60 f8 10 80       	push   $0x8010f860
80102bc8:	e8 f9 1f 00 00       	call   80104bc6 <acquire>
80102bcd:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102bd0:	a1 98 f8 10 80       	mov    0x8010f898,%eax
80102bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102bd8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bdc:	74 0a                	je     80102be8 <kalloc+0x37>
    kmem.freelist = r->next;
80102bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be1:	8b 00                	mov    (%eax),%eax
80102be3:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102be8:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102bed:	85 c0                	test   %eax,%eax
80102bef:	74 10                	je     80102c01 <kalloc+0x50>
    release(&kmem.lock);
80102bf1:	83 ec 0c             	sub    $0xc,%esp
80102bf4:	68 60 f8 10 80       	push   $0x8010f860
80102bf9:	e8 2f 20 00 00       	call   80104c2d <release>
80102bfe:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c04:	c9                   	leave  
80102c05:	c3                   	ret    

80102c06 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c06:	55                   	push   %ebp
80102c07:	89 e5                	mov    %esp,%ebp
80102c09:	83 ec 14             	sub    $0x14,%esp
80102c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80102c0f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c13:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c17:	89 c2                	mov    %eax,%edx
80102c19:	ec                   	in     (%dx),%al
80102c1a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c1d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c21:	c9                   	leave  
80102c22:	c3                   	ret    

80102c23 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c23:	55                   	push   %ebp
80102c24:	89 e5                	mov    %esp,%ebp
80102c26:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102c29:	6a 64                	push   $0x64
80102c2b:	e8 d6 ff ff ff       	call   80102c06 <inb>
80102c30:	83 c4 04             	add    $0x4,%esp
80102c33:	0f b6 c0             	movzbl %al,%eax
80102c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c3c:	83 e0 01             	and    $0x1,%eax
80102c3f:	85 c0                	test   %eax,%eax
80102c41:	75 0a                	jne    80102c4d <kbdgetc+0x2a>
    return -1;
80102c43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c48:	e9 23 01 00 00       	jmp    80102d70 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102c4d:	6a 60                	push   $0x60
80102c4f:	e8 b2 ff ff ff       	call   80102c06 <inb>
80102c54:	83 c4 04             	add    $0x4,%esp
80102c57:	0f b6 c0             	movzbl %al,%eax
80102c5a:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c5d:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c64:	75 17                	jne    80102c7d <kbdgetc+0x5a>
    shift |= E0ESC;
80102c66:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c6b:	83 c8 40             	or     $0x40,%eax
80102c6e:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102c73:	b8 00 00 00 00       	mov    $0x0,%eax
80102c78:	e9 f3 00 00 00       	jmp    80102d70 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102c7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c80:	25 80 00 00 00       	and    $0x80,%eax
80102c85:	85 c0                	test   %eax,%eax
80102c87:	74 45                	je     80102cce <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c89:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c8e:	83 e0 40             	and    $0x40,%eax
80102c91:	85 c0                	test   %eax,%eax
80102c93:	75 08                	jne    80102c9d <kbdgetc+0x7a>
80102c95:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c98:	83 e0 7f             	and    $0x7f,%eax
80102c9b:	eb 03                	jmp    80102ca0 <kbdgetc+0x7d>
80102c9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ca0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102ca3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ca6:	05 20 90 10 80       	add    $0x80109020,%eax
80102cab:	0f b6 00             	movzbl (%eax),%eax
80102cae:	83 c8 40             	or     $0x40,%eax
80102cb1:	0f b6 c0             	movzbl %al,%eax
80102cb4:	f7 d0                	not    %eax
80102cb6:	89 c2                	mov    %eax,%edx
80102cb8:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cbd:	21 d0                	and    %edx,%eax
80102cbf:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102cc4:	b8 00 00 00 00       	mov    $0x0,%eax
80102cc9:	e9 a2 00 00 00       	jmp    80102d70 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102cce:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cd3:	83 e0 40             	and    $0x40,%eax
80102cd6:	85 c0                	test   %eax,%eax
80102cd8:	74 14                	je     80102cee <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102cda:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102ce1:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102ce6:	83 e0 bf             	and    $0xffffffbf,%eax
80102ce9:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  }

  shift |= shiftcode[data];
80102cee:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cf1:	05 20 90 10 80       	add    $0x80109020,%eax
80102cf6:	0f b6 00             	movzbl (%eax),%eax
80102cf9:	0f b6 d0             	movzbl %al,%edx
80102cfc:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d01:	09 d0                	or     %edx,%eax
80102d03:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  shift ^= togglecode[data];
80102d08:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d0b:	05 20 91 10 80       	add    $0x80109120,%eax
80102d10:	0f b6 00             	movzbl (%eax),%eax
80102d13:	0f b6 d0             	movzbl %al,%edx
80102d16:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d1b:	31 d0                	xor    %edx,%eax
80102d1d:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102d22:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d27:	83 e0 03             	and    $0x3,%eax
80102d2a:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102d31:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d34:	01 d0                	add    %edx,%eax
80102d36:	0f b6 00             	movzbl (%eax),%eax
80102d39:	0f b6 c0             	movzbl %al,%eax
80102d3c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d3f:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d44:	83 e0 08             	and    $0x8,%eax
80102d47:	85 c0                	test   %eax,%eax
80102d49:	74 22                	je     80102d6d <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102d4b:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d4f:	76 0c                	jbe    80102d5d <kbdgetc+0x13a>
80102d51:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d55:	77 06                	ja     80102d5d <kbdgetc+0x13a>
      c += 'A' - 'a';
80102d57:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d5b:	eb 10                	jmp    80102d6d <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102d5d:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d61:	76 0a                	jbe    80102d6d <kbdgetc+0x14a>
80102d63:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d67:	77 04                	ja     80102d6d <kbdgetc+0x14a>
      c += 'a' - 'A';
80102d69:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d6d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d70:	c9                   	leave  
80102d71:	c3                   	ret    

80102d72 <kbdintr>:

void
kbdintr(void)
{
80102d72:	55                   	push   %ebp
80102d73:	89 e5                	mov    %esp,%ebp
80102d75:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102d78:	83 ec 0c             	sub    $0xc,%esp
80102d7b:	68 23 2c 10 80       	push   $0x80102c23
80102d80:	e8 58 da ff ff       	call   801007dd <consoleintr>
80102d85:	83 c4 10             	add    $0x10,%esp
}
80102d88:	90                   	nop
80102d89:	c9                   	leave  
80102d8a:	c3                   	ret    

80102d8b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d8b:	55                   	push   %ebp
80102d8c:	89 e5                	mov    %esp,%ebp
80102d8e:	83 ec 08             	sub    $0x8,%esp
80102d91:	8b 55 08             	mov    0x8(%ebp),%edx
80102d94:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d97:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d9b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d9e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102da2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102da6:	ee                   	out    %al,(%dx)
}
80102da7:	90                   	nop
80102da8:	c9                   	leave  
80102da9:	c3                   	ret    

80102daa <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102daa:	55                   	push   %ebp
80102dab:	89 e5                	mov    %esp,%ebp
80102dad:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102db0:	9c                   	pushf  
80102db1:	58                   	pop    %eax
80102db2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102db5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102db8:	c9                   	leave  
80102db9:	c3                   	ret    

80102dba <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102dba:	55                   	push   %ebp
80102dbb:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102dbd:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102dc2:	8b 55 08             	mov    0x8(%ebp),%edx
80102dc5:	c1 e2 02             	shl    $0x2,%edx
80102dc8:	01 c2                	add    %eax,%edx
80102dca:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dcd:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102dcf:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102dd4:	83 c0 20             	add    $0x20,%eax
80102dd7:	8b 00                	mov    (%eax),%eax
}
80102dd9:	90                   	nop
80102dda:	5d                   	pop    %ebp
80102ddb:	c3                   	ret    

80102ddc <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102ddc:	55                   	push   %ebp
80102ddd:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102ddf:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102de4:	85 c0                	test   %eax,%eax
80102de6:	0f 84 0b 01 00 00    	je     80102ef7 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102dec:	68 3f 01 00 00       	push   $0x13f
80102df1:	6a 3c                	push   $0x3c
80102df3:	e8 c2 ff ff ff       	call   80102dba <lapicw>
80102df8:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102dfb:	6a 0b                	push   $0xb
80102dfd:	68 f8 00 00 00       	push   $0xf8
80102e02:	e8 b3 ff ff ff       	call   80102dba <lapicw>
80102e07:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102e0a:	68 20 00 02 00       	push   $0x20020
80102e0f:	68 c8 00 00 00       	push   $0xc8
80102e14:	e8 a1 ff ff ff       	call   80102dba <lapicw>
80102e19:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102e1c:	68 80 96 98 00       	push   $0x989680
80102e21:	68 e0 00 00 00       	push   $0xe0
80102e26:	e8 8f ff ff ff       	call   80102dba <lapicw>
80102e2b:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e2e:	68 00 00 01 00       	push   $0x10000
80102e33:	68 d4 00 00 00       	push   $0xd4
80102e38:	e8 7d ff ff ff       	call   80102dba <lapicw>
80102e3d:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102e40:	68 00 00 01 00       	push   $0x10000
80102e45:	68 d8 00 00 00       	push   $0xd8
80102e4a:	e8 6b ff ff ff       	call   80102dba <lapicw>
80102e4f:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e52:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102e57:	83 c0 30             	add    $0x30,%eax
80102e5a:	8b 00                	mov    (%eax),%eax
80102e5c:	c1 e8 10             	shr    $0x10,%eax
80102e5f:	0f b6 c0             	movzbl %al,%eax
80102e62:	83 f8 03             	cmp    $0x3,%eax
80102e65:	76 12                	jbe    80102e79 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102e67:	68 00 00 01 00       	push   $0x10000
80102e6c:	68 d0 00 00 00       	push   $0xd0
80102e71:	e8 44 ff ff ff       	call   80102dba <lapicw>
80102e76:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e79:	6a 33                	push   $0x33
80102e7b:	68 dc 00 00 00       	push   $0xdc
80102e80:	e8 35 ff ff ff       	call   80102dba <lapicw>
80102e85:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e88:	6a 00                	push   $0x0
80102e8a:	68 a0 00 00 00       	push   $0xa0
80102e8f:	e8 26 ff ff ff       	call   80102dba <lapicw>
80102e94:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102e97:	6a 00                	push   $0x0
80102e99:	68 a0 00 00 00       	push   $0xa0
80102e9e:	e8 17 ff ff ff       	call   80102dba <lapicw>
80102ea3:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102ea6:	6a 00                	push   $0x0
80102ea8:	6a 2c                	push   $0x2c
80102eaa:	e8 0b ff ff ff       	call   80102dba <lapicw>
80102eaf:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102eb2:	6a 00                	push   $0x0
80102eb4:	68 c4 00 00 00       	push   $0xc4
80102eb9:	e8 fc fe ff ff       	call   80102dba <lapicw>
80102ebe:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ec1:	68 00 85 08 00       	push   $0x88500
80102ec6:	68 c0 00 00 00       	push   $0xc0
80102ecb:	e8 ea fe ff ff       	call   80102dba <lapicw>
80102ed0:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ed3:	90                   	nop
80102ed4:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102ed9:	05 00 03 00 00       	add    $0x300,%eax
80102ede:	8b 00                	mov    (%eax),%eax
80102ee0:	25 00 10 00 00       	and    $0x1000,%eax
80102ee5:	85 c0                	test   %eax,%eax
80102ee7:	75 eb                	jne    80102ed4 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ee9:	6a 00                	push   $0x0
80102eeb:	6a 20                	push   $0x20
80102eed:	e8 c8 fe ff ff       	call   80102dba <lapicw>
80102ef2:	83 c4 08             	add    $0x8,%esp
80102ef5:	eb 01                	jmp    80102ef8 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102ef7:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102ef8:	c9                   	leave  
80102ef9:	c3                   	ret    

80102efa <cpunum>:

int
cpunum(void)
{
80102efa:	55                   	push   %ebp
80102efb:	89 e5                	mov    %esp,%ebp
80102efd:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102f00:	e8 a5 fe ff ff       	call   80102daa <readeflags>
80102f05:	25 00 02 00 00       	and    $0x200,%eax
80102f0a:	85 c0                	test   %eax,%eax
80102f0c:	74 26                	je     80102f34 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102f0e:	a1 60 b6 10 80       	mov    0x8010b660,%eax
80102f13:	8d 50 01             	lea    0x1(%eax),%edx
80102f16:	89 15 60 b6 10 80    	mov    %edx,0x8010b660
80102f1c:	85 c0                	test   %eax,%eax
80102f1e:	75 14                	jne    80102f34 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f20:	8b 45 04             	mov    0x4(%ebp),%eax
80102f23:	83 ec 08             	sub    $0x8,%esp
80102f26:	50                   	push   %eax
80102f27:	68 60 83 10 80       	push   $0x80108360
80102f2c:	e8 95 d4 ff ff       	call   801003c6 <cprintf>
80102f31:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80102f34:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102f39:	85 c0                	test   %eax,%eax
80102f3b:	74 0f                	je     80102f4c <cpunum+0x52>
    return lapic[ID]>>24;
80102f3d:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102f42:	83 c0 20             	add    $0x20,%eax
80102f45:	8b 00                	mov    (%eax),%eax
80102f47:	c1 e8 18             	shr    $0x18,%eax
80102f4a:	eb 05                	jmp    80102f51 <cpunum+0x57>
  return 0;
80102f4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f51:	c9                   	leave  
80102f52:	c3                   	ret    

80102f53 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f53:	55                   	push   %ebp
80102f54:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102f56:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102f5b:	85 c0                	test   %eax,%eax
80102f5d:	74 0c                	je     80102f6b <lapiceoi+0x18>
    lapicw(EOI, 0);
80102f5f:	6a 00                	push   $0x0
80102f61:	6a 2c                	push   $0x2c
80102f63:	e8 52 fe ff ff       	call   80102dba <lapicw>
80102f68:	83 c4 08             	add    $0x8,%esp
}
80102f6b:	90                   	nop
80102f6c:	c9                   	leave  
80102f6d:	c3                   	ret    

80102f6e <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f6e:	55                   	push   %ebp
80102f6f:	89 e5                	mov    %esp,%ebp
}
80102f71:	90                   	nop
80102f72:	5d                   	pop    %ebp
80102f73:	c3                   	ret    

80102f74 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f74:	55                   	push   %ebp
80102f75:	89 e5                	mov    %esp,%ebp
80102f77:	83 ec 14             	sub    $0x14,%esp
80102f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80102f7d:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80102f80:	6a 0f                	push   $0xf
80102f82:	6a 70                	push   $0x70
80102f84:	e8 02 fe ff ff       	call   80102d8b <outb>
80102f89:	83 c4 08             	add    $0x8,%esp
  outb(IO_RTC+1, 0x0A);
80102f8c:	6a 0a                	push   $0xa
80102f8e:	6a 71                	push   $0x71
80102f90:	e8 f6 fd ff ff       	call   80102d8b <outb>
80102f95:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f98:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f9f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fa2:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102fa7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102faa:	83 c0 02             	add    $0x2,%eax
80102fad:	8b 55 0c             	mov    0xc(%ebp),%edx
80102fb0:	c1 ea 04             	shr    $0x4,%edx
80102fb3:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102fb6:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fba:	c1 e0 18             	shl    $0x18,%eax
80102fbd:	50                   	push   %eax
80102fbe:	68 c4 00 00 00       	push   $0xc4
80102fc3:	e8 f2 fd ff ff       	call   80102dba <lapicw>
80102fc8:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102fcb:	68 00 c5 00 00       	push   $0xc500
80102fd0:	68 c0 00 00 00       	push   $0xc0
80102fd5:	e8 e0 fd ff ff       	call   80102dba <lapicw>
80102fda:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102fdd:	68 c8 00 00 00       	push   $0xc8
80102fe2:	e8 87 ff ff ff       	call   80102f6e <microdelay>
80102fe7:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102fea:	68 00 85 00 00       	push   $0x8500
80102fef:	68 c0 00 00 00       	push   $0xc0
80102ff4:	e8 c1 fd ff ff       	call   80102dba <lapicw>
80102ff9:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102ffc:	6a 64                	push   $0x64
80102ffe:	e8 6b ff ff ff       	call   80102f6e <microdelay>
80103003:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103006:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010300d:	eb 3d                	jmp    8010304c <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
8010300f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103013:	c1 e0 18             	shl    $0x18,%eax
80103016:	50                   	push   %eax
80103017:	68 c4 00 00 00       	push   $0xc4
8010301c:	e8 99 fd ff ff       	call   80102dba <lapicw>
80103021:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103024:	8b 45 0c             	mov    0xc(%ebp),%eax
80103027:	c1 e8 0c             	shr    $0xc,%eax
8010302a:	80 cc 06             	or     $0x6,%ah
8010302d:	50                   	push   %eax
8010302e:	68 c0 00 00 00       	push   $0xc0
80103033:	e8 82 fd ff ff       	call   80102dba <lapicw>
80103038:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010303b:	68 c8 00 00 00       	push   $0xc8
80103040:	e8 29 ff ff ff       	call   80102f6e <microdelay>
80103045:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103048:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010304c:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103050:	7e bd                	jle    8010300f <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103052:	90                   	nop
80103053:	c9                   	leave  
80103054:	c3                   	ret    

80103055 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103055:	55                   	push   %ebp
80103056:	89 e5                	mov    %esp,%ebp
80103058:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010305b:	83 ec 08             	sub    $0x8,%esp
8010305e:	68 8c 83 10 80       	push   $0x8010838c
80103063:	68 a0 f8 10 80       	push   $0x8010f8a0
80103068:	e8 37 1b 00 00       	call   80104ba4 <initlock>
8010306d:	83 c4 10             	add    $0x10,%esp
  readsb(ROOTDEV, &sb);
80103070:	83 ec 08             	sub    $0x8,%esp
80103073:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103076:	50                   	push   %eax
80103077:	6a 01                	push   $0x1
80103079:	e8 d7 e2 ff ff       	call   80101355 <readsb>
8010307e:	83 c4 10             	add    $0x10,%esp
  log.start = sb.size - sb.nlog;
80103081:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103084:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103087:	29 c2                	sub    %eax,%edx
80103089:	89 d0                	mov    %edx,%eax
8010308b:	a3 d4 f8 10 80       	mov    %eax,0x8010f8d4
  log.size = sb.nlog;
80103090:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103093:	a3 d8 f8 10 80       	mov    %eax,0x8010f8d8
  log.dev = ROOTDEV;
80103098:	c7 05 e0 f8 10 80 01 	movl   $0x1,0x8010f8e0
8010309f:	00 00 00 
  recover_from_log();
801030a2:	e8 b2 01 00 00       	call   80103259 <recover_from_log>
}
801030a7:	90                   	nop
801030a8:	c9                   	leave  
801030a9:	c3                   	ret    

801030aa <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801030aa:	55                   	push   %ebp
801030ab:	89 e5                	mov    %esp,%ebp
801030ad:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801030b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801030b7:	e9 95 00 00 00       	jmp    80103151 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801030bc:	8b 15 d4 f8 10 80    	mov    0x8010f8d4,%edx
801030c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030c5:	01 d0                	add    %edx,%eax
801030c7:	83 c0 01             	add    $0x1,%eax
801030ca:	89 c2                	mov    %eax,%edx
801030cc:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801030d1:	83 ec 08             	sub    $0x8,%esp
801030d4:	52                   	push   %edx
801030d5:	50                   	push   %eax
801030d6:	e8 db d0 ff ff       	call   801001b6 <bread>
801030db:	83 c4 10             	add    $0x10,%esp
801030de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801030e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030e4:	83 c0 10             	add    $0x10,%eax
801030e7:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
801030ee:	89 c2                	mov    %eax,%edx
801030f0:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801030f5:	83 ec 08             	sub    $0x8,%esp
801030f8:	52                   	push   %edx
801030f9:	50                   	push   %eax
801030fa:	e8 b7 d0 ff ff       	call   801001b6 <bread>
801030ff:	83 c4 10             	add    $0x10,%esp
80103102:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103105:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103108:	8d 50 18             	lea    0x18(%eax),%edx
8010310b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010310e:	83 c0 18             	add    $0x18,%eax
80103111:	83 ec 04             	sub    $0x4,%esp
80103114:	68 00 02 00 00       	push   $0x200
80103119:	52                   	push   %edx
8010311a:	50                   	push   %eax
8010311b:	e8 c8 1d 00 00       	call   80104ee8 <memmove>
80103120:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103123:	83 ec 0c             	sub    $0xc,%esp
80103126:	ff 75 ec             	pushl  -0x14(%ebp)
80103129:	e8 c1 d0 ff ff       	call   801001ef <bwrite>
8010312e:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103131:	83 ec 0c             	sub    $0xc,%esp
80103134:	ff 75 f0             	pushl  -0x10(%ebp)
80103137:	e8 f2 d0 ff ff       	call   8010022e <brelse>
8010313c:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010313f:	83 ec 0c             	sub    $0xc,%esp
80103142:	ff 75 ec             	pushl  -0x14(%ebp)
80103145:	e8 e4 d0 ff ff       	call   8010022e <brelse>
8010314a:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010314d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103151:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103156:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103159:	0f 8f 5d ff ff ff    	jg     801030bc <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
8010315f:	90                   	nop
80103160:	c9                   	leave  
80103161:	c3                   	ret    

80103162 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103162:	55                   	push   %ebp
80103163:	89 e5                	mov    %esp,%ebp
80103165:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103168:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
8010316d:	89 c2                	mov    %eax,%edx
8010316f:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103174:	83 ec 08             	sub    $0x8,%esp
80103177:	52                   	push   %edx
80103178:	50                   	push   %eax
80103179:	e8 38 d0 ff ff       	call   801001b6 <bread>
8010317e:	83 c4 10             	add    $0x10,%esp
80103181:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103184:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103187:	83 c0 18             	add    $0x18,%eax
8010318a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010318d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103190:	8b 00                	mov    (%eax),%eax
80103192:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  for (i = 0; i < log.lh.n; i++) {
80103197:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010319e:	eb 1b                	jmp    801031bb <read_head+0x59>
    log.lh.sector[i] = lh->sector[i];
801031a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801031a6:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801031aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801031ad:	83 c2 10             	add    $0x10,%edx
801031b0:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801031b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801031bb:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801031c0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801031c3:	7f db                	jg     801031a0 <read_head+0x3e>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801031c5:	83 ec 0c             	sub    $0xc,%esp
801031c8:	ff 75 f0             	pushl  -0x10(%ebp)
801031cb:	e8 5e d0 ff ff       	call   8010022e <brelse>
801031d0:	83 c4 10             	add    $0x10,%esp
}
801031d3:	90                   	nop
801031d4:	c9                   	leave  
801031d5:	c3                   	ret    

801031d6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801031d6:	55                   	push   %ebp
801031d7:	89 e5                	mov    %esp,%ebp
801031d9:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801031dc:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801031e1:	89 c2                	mov    %eax,%edx
801031e3:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801031e8:	83 ec 08             	sub    $0x8,%esp
801031eb:	52                   	push   %edx
801031ec:	50                   	push   %eax
801031ed:	e8 c4 cf ff ff       	call   801001b6 <bread>
801031f2:	83 c4 10             	add    $0x10,%esp
801031f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801031f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031fb:	83 c0 18             	add    $0x18,%eax
801031fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103201:	8b 15 e4 f8 10 80    	mov    0x8010f8e4,%edx
80103207:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010320a:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010320c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103213:	eb 1b                	jmp    80103230 <write_head+0x5a>
    hb->sector[i] = log.lh.sector[i];
80103215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103218:	83 c0 10             	add    $0x10,%eax
8010321b:	8b 0c 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%ecx
80103222:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103225:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103228:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010322c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103230:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103235:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103238:	7f db                	jg     80103215 <write_head+0x3f>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
8010323a:	83 ec 0c             	sub    $0xc,%esp
8010323d:	ff 75 f0             	pushl  -0x10(%ebp)
80103240:	e8 aa cf ff ff       	call   801001ef <bwrite>
80103245:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103248:	83 ec 0c             	sub    $0xc,%esp
8010324b:	ff 75 f0             	pushl  -0x10(%ebp)
8010324e:	e8 db cf ff ff       	call   8010022e <brelse>
80103253:	83 c4 10             	add    $0x10,%esp
}
80103256:	90                   	nop
80103257:	c9                   	leave  
80103258:	c3                   	ret    

80103259 <recover_from_log>:

static void
recover_from_log(void)
{
80103259:	55                   	push   %ebp
8010325a:	89 e5                	mov    %esp,%ebp
8010325c:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010325f:	e8 fe fe ff ff       	call   80103162 <read_head>
  install_trans(); // if committed, copy from log to disk
80103264:	e8 41 fe ff ff       	call   801030aa <install_trans>
  log.lh.n = 0;
80103269:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
80103270:	00 00 00 
  write_head(); // clear the log
80103273:	e8 5e ff ff ff       	call   801031d6 <write_head>
}
80103278:	90                   	nop
80103279:	c9                   	leave  
8010327a:	c3                   	ret    

8010327b <begin_trans>:

void
begin_trans(void)
{
8010327b:	55                   	push   %ebp
8010327c:	89 e5                	mov    %esp,%ebp
8010327e:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103281:	83 ec 0c             	sub    $0xc,%esp
80103284:	68 a0 f8 10 80       	push   $0x8010f8a0
80103289:	e8 38 19 00 00       	call   80104bc6 <acquire>
8010328e:	83 c4 10             	add    $0x10,%esp
  while (log.busy) {
80103291:	eb 15                	jmp    801032a8 <begin_trans+0x2d>
    sleep(&log, &log.lock);
80103293:	83 ec 08             	sub    $0x8,%esp
80103296:	68 a0 f8 10 80       	push   $0x8010f8a0
8010329b:	68 a0 f8 10 80       	push   $0x8010f8a0
801032a0:	e8 28 16 00 00       	call   801048cd <sleep>
801032a5:	83 c4 10             	add    $0x10,%esp

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
801032a8:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
801032ad:	85 c0                	test   %eax,%eax
801032af:	75 e2                	jne    80103293 <begin_trans+0x18>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
801032b1:	c7 05 dc f8 10 80 01 	movl   $0x1,0x8010f8dc
801032b8:	00 00 00 
  release(&log.lock);
801032bb:	83 ec 0c             	sub    $0xc,%esp
801032be:	68 a0 f8 10 80       	push   $0x8010f8a0
801032c3:	e8 65 19 00 00       	call   80104c2d <release>
801032c8:	83 c4 10             	add    $0x10,%esp
}
801032cb:	90                   	nop
801032cc:	c9                   	leave  
801032cd:	c3                   	ret    

801032ce <commit_trans>:

void
commit_trans(void)
{
801032ce:	55                   	push   %ebp
801032cf:	89 e5                	mov    %esp,%ebp
801032d1:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801032d4:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801032d9:	85 c0                	test   %eax,%eax
801032db:	7e 19                	jle    801032f6 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
801032dd:	e8 f4 fe ff ff       	call   801031d6 <write_head>
    install_trans(); // Now install writes to home locations
801032e2:	e8 c3 fd ff ff       	call   801030aa <install_trans>
    log.lh.n = 0; 
801032e7:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
801032ee:	00 00 00 
    write_head();    // Erase the transaction from the log
801032f1:	e8 e0 fe ff ff       	call   801031d6 <write_head>
  }
  
  acquire(&log.lock);
801032f6:	83 ec 0c             	sub    $0xc,%esp
801032f9:	68 a0 f8 10 80       	push   $0x8010f8a0
801032fe:	e8 c3 18 00 00       	call   80104bc6 <acquire>
80103303:	83 c4 10             	add    $0x10,%esp
  log.busy = 0;
80103306:	c7 05 dc f8 10 80 00 	movl   $0x0,0x8010f8dc
8010330d:	00 00 00 
  wakeup(&log);
80103310:	83 ec 0c             	sub    $0xc,%esp
80103313:	68 a0 f8 10 80       	push   $0x8010f8a0
80103318:	e8 9b 16 00 00       	call   801049b8 <wakeup>
8010331d:	83 c4 10             	add    $0x10,%esp
  release(&log.lock);
80103320:	83 ec 0c             	sub    $0xc,%esp
80103323:	68 a0 f8 10 80       	push   $0x8010f8a0
80103328:	e8 00 19 00 00       	call   80104c2d <release>
8010332d:	83 c4 10             	add    $0x10,%esp
}
80103330:	90                   	nop
80103331:	c9                   	leave  
80103332:	c3                   	ret    

80103333 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103333:	55                   	push   %ebp
80103334:	89 e5                	mov    %esp,%ebp
80103336:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103339:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010333e:	83 f8 09             	cmp    $0x9,%eax
80103341:	7f 12                	jg     80103355 <log_write+0x22>
80103343:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103348:	8b 15 d8 f8 10 80    	mov    0x8010f8d8,%edx
8010334e:	83 ea 01             	sub    $0x1,%edx
80103351:	39 d0                	cmp    %edx,%eax
80103353:	7c 0d                	jl     80103362 <log_write+0x2f>
    panic("too big a transaction");
80103355:	83 ec 0c             	sub    $0xc,%esp
80103358:	68 90 83 10 80       	push   $0x80108390
8010335d:	e8 04 d2 ff ff       	call   80100566 <panic>
  if (!log.busy)
80103362:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103367:	85 c0                	test   %eax,%eax
80103369:	75 0d                	jne    80103378 <log_write+0x45>
    panic("write outside of trans");
8010336b:	83 ec 0c             	sub    $0xc,%esp
8010336e:	68 a6 83 10 80       	push   $0x801083a6
80103373:	e8 ee d1 ff ff       	call   80100566 <panic>

  for (i = 0; i < log.lh.n; i++) {
80103378:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010337f:	eb 1d                	jmp    8010339e <log_write+0x6b>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
80103381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103384:	83 c0 10             	add    $0x10,%eax
80103387:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
8010338e:	89 c2                	mov    %eax,%edx
80103390:	8b 45 08             	mov    0x8(%ebp),%eax
80103393:	8b 40 08             	mov    0x8(%eax),%eax
80103396:	39 c2                	cmp    %eax,%edx
80103398:	74 10                	je     801033aa <log_write+0x77>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
8010339a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010339e:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801033a3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033a6:	7f d9                	jg     80103381 <log_write+0x4e>
801033a8:	eb 01                	jmp    801033ab <log_write+0x78>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
801033aa:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
801033ab:	8b 45 08             	mov    0x8(%ebp),%eax
801033ae:	8b 40 08             	mov    0x8(%eax),%eax
801033b1:	89 c2                	mov    %eax,%edx
801033b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b6:	83 c0 10             	add    $0x10,%eax
801033b9:	89 14 85 a8 f8 10 80 	mov    %edx,-0x7fef0758(,%eax,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
801033c0:	8b 15 d4 f8 10 80    	mov    0x8010f8d4,%edx
801033c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033c9:	01 d0                	add    %edx,%eax
801033cb:	83 c0 01             	add    $0x1,%eax
801033ce:	89 c2                	mov    %eax,%edx
801033d0:	8b 45 08             	mov    0x8(%ebp),%eax
801033d3:	8b 40 04             	mov    0x4(%eax),%eax
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	52                   	push   %edx
801033da:	50                   	push   %eax
801033db:	e8 d6 cd ff ff       	call   801001b6 <bread>
801033e0:	83 c4 10             	add    $0x10,%esp
801033e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
801033e6:	8b 45 08             	mov    0x8(%ebp),%eax
801033e9:	8d 50 18             	lea    0x18(%eax),%edx
801033ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033ef:	83 c0 18             	add    $0x18,%eax
801033f2:	83 ec 04             	sub    $0x4,%esp
801033f5:	68 00 02 00 00       	push   $0x200
801033fa:	52                   	push   %edx
801033fb:	50                   	push   %eax
801033fc:	e8 e7 1a 00 00       	call   80104ee8 <memmove>
80103401:	83 c4 10             	add    $0x10,%esp
  bwrite(lbuf);
80103404:	83 ec 0c             	sub    $0xc,%esp
80103407:	ff 75 f0             	pushl  -0x10(%ebp)
8010340a:	e8 e0 cd ff ff       	call   801001ef <bwrite>
8010340f:	83 c4 10             	add    $0x10,%esp
  brelse(lbuf);
80103412:	83 ec 0c             	sub    $0xc,%esp
80103415:	ff 75 f0             	pushl  -0x10(%ebp)
80103418:	e8 11 ce ff ff       	call   8010022e <brelse>
8010341d:	83 c4 10             	add    $0x10,%esp
  if (i == log.lh.n)
80103420:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103425:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103428:	75 0d                	jne    80103437 <log_write+0x104>
    log.lh.n++;
8010342a:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010342f:	83 c0 01             	add    $0x1,%eax
80103432:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  b->flags |= B_DIRTY; // XXX prevent eviction
80103437:	8b 45 08             	mov    0x8(%ebp),%eax
8010343a:	8b 00                	mov    (%eax),%eax
8010343c:	83 c8 04             	or     $0x4,%eax
8010343f:	89 c2                	mov    %eax,%edx
80103441:	8b 45 08             	mov    0x8(%ebp),%eax
80103444:	89 10                	mov    %edx,(%eax)
}
80103446:	90                   	nop
80103447:	c9                   	leave  
80103448:	c3                   	ret    

80103449 <v2p>:
80103449:	55                   	push   %ebp
8010344a:	89 e5                	mov    %esp,%ebp
8010344c:	8b 45 08             	mov    0x8(%ebp),%eax
8010344f:	05 00 00 00 80       	add    $0x80000000,%eax
80103454:	5d                   	pop    %ebp
80103455:	c3                   	ret    

80103456 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103456:	55                   	push   %ebp
80103457:	89 e5                	mov    %esp,%ebp
80103459:	8b 45 08             	mov    0x8(%ebp),%eax
8010345c:	05 00 00 00 80       	add    $0x80000000,%eax
80103461:	5d                   	pop    %ebp
80103462:	c3                   	ret    

80103463 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103463:	55                   	push   %ebp
80103464:	89 e5                	mov    %esp,%ebp
80103466:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103469:	8b 55 08             	mov    0x8(%ebp),%edx
8010346c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010346f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103472:	f0 87 02             	lock xchg %eax,(%edx)
80103475:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103478:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010347b:	c9                   	leave  
8010347c:	c3                   	ret    

8010347d <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010347d:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103481:	83 e4 f0             	and    $0xfffffff0,%esp
80103484:	ff 71 fc             	pushl  -0x4(%ecx)
80103487:	55                   	push   %ebp
80103488:	89 e5                	mov    %esp,%ebp
8010348a:	51                   	push   %ecx
8010348b:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010348e:	83 ec 08             	sub    $0x8,%esp
80103491:	68 00 00 40 80       	push   $0x80400000
80103496:	68 3c 27 11 80       	push   $0x8011273c
8010349b:	e8 da f5 ff ff       	call   80102a7a <kinit1>
801034a0:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034a3:	e8 69 45 00 00       	call   80107a11 <kvmalloc>
  mpinit();        // collect info about this machine
801034a8:	e8 52 04 00 00       	call   801038ff <mpinit>
  lapicinit();
801034ad:	e8 2a f9 ff ff       	call   80102ddc <lapicinit>
  seginit();       // set up segments
801034b2:	e8 fe 3e 00 00       	call   801073b5 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801034b7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801034bd:	0f b6 00             	movzbl (%eax),%eax
801034c0:	0f b6 c0             	movzbl %al,%eax
801034c3:	83 ec 08             	sub    $0x8,%esp
801034c6:	50                   	push   %eax
801034c7:	68 bd 83 10 80       	push   $0x801083bd
801034cc:	e8 f5 ce ff ff       	call   801003c6 <cprintf>
801034d1:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801034d4:	e8 85 06 00 00       	call   80103b5e <picinit>
  ioapicinit();    // another interrupt controller
801034d9:	e8 91 f4 ff ff       	call   8010296f <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801034de:	e8 06 d6 ff ff       	call   80100ae9 <consoleinit>
  uartinit();      // serial port
801034e3:	e8 29 32 00 00       	call   80106711 <uartinit>
  pinit();         // process table
801034e8:	e8 6e 0b 00 00       	call   8010405b <pinit>
  tvinit();        // trap vectors
801034ed:	e8 e9 2d 00 00       	call   801062db <tvinit>
  binit();         // buffer cache
801034f2:	e8 3d cb ff ff       	call   80100034 <binit>
  fileinit();      // file table
801034f7:	e8 4a da ff ff       	call   80100f46 <fileinit>
  iinit();         // inode cache
801034fc:	e8 23 e1 ff ff       	call   80101624 <iinit>
  ideinit();       // disk
80103501:	e8 ad f0 ff ff       	call   801025b3 <ideinit>
  if(!ismp)
80103506:	a1 24 f9 10 80       	mov    0x8010f924,%eax
8010350b:	85 c0                	test   %eax,%eax
8010350d:	75 05                	jne    80103514 <main+0x97>
    timerinit();   // uniprocessor timer
8010350f:	e8 24 2d 00 00       	call   80106238 <timerinit>
  startothers();   // start other processors
80103514:	e8 7f 00 00 00       	call   80103598 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103519:	83 ec 08             	sub    $0x8,%esp
8010351c:	68 00 00 00 8e       	push   $0x8e000000
80103521:	68 00 00 40 80       	push   $0x80400000
80103526:	e8 88 f5 ff ff       	call   80102ab3 <kinit2>
8010352b:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010352e:	e8 4c 0c 00 00       	call   8010417f <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103533:	e8 1a 00 00 00       	call   80103552 <mpmain>

80103538 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103538:	55                   	push   %ebp
80103539:	89 e5                	mov    %esp,%ebp
8010353b:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010353e:	e8 e6 44 00 00       	call   80107a29 <switchkvm>
  seginit();
80103543:	e8 6d 3e 00 00       	call   801073b5 <seginit>
  lapicinit();
80103548:	e8 8f f8 ff ff       	call   80102ddc <lapicinit>
  mpmain();
8010354d:	e8 00 00 00 00       	call   80103552 <mpmain>

80103552 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103552:	55                   	push   %ebp
80103553:	89 e5                	mov    %esp,%ebp
80103555:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103558:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010355e:	0f b6 00             	movzbl (%eax),%eax
80103561:	0f b6 c0             	movzbl %al,%eax
80103564:	83 ec 08             	sub    $0x8,%esp
80103567:	50                   	push   %eax
80103568:	68 d4 83 10 80       	push   $0x801083d4
8010356d:	e8 54 ce ff ff       	call   801003c6 <cprintf>
80103572:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103575:	e8 d7 2e 00 00       	call   80106451 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010357a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103580:	05 a8 00 00 00       	add    $0xa8,%eax
80103585:	83 ec 08             	sub    $0x8,%esp
80103588:	6a 01                	push   $0x1
8010358a:	50                   	push   %eax
8010358b:	e8 d3 fe ff ff       	call   80103463 <xchg>
80103590:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103593:	e8 68 11 00 00       	call   80104700 <scheduler>

80103598 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103598:	55                   	push   %ebp
80103599:	89 e5                	mov    %esp,%ebp
8010359b:	53                   	push   %ebx
8010359c:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010359f:	68 00 70 00 00       	push   $0x7000
801035a4:	e8 ad fe ff ff       	call   80103456 <p2v>
801035a9:	83 c4 04             	add    $0x4,%esp
801035ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801035af:	b8 8a 00 00 00       	mov    $0x8a,%eax
801035b4:	83 ec 04             	sub    $0x4,%esp
801035b7:	50                   	push   %eax
801035b8:	68 2c b5 10 80       	push   $0x8010b52c
801035bd:	ff 75 f0             	pushl  -0x10(%ebp)
801035c0:	e8 23 19 00 00       	call   80104ee8 <memmove>
801035c5:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801035c8:	c7 45 f4 40 f9 10 80 	movl   $0x8010f940,-0xc(%ebp)
801035cf:	e9 95 00 00 00       	jmp    80103669 <startothers+0xd1>
    if(c == cpus+cpunum())  // We've started already.
801035d4:	e8 21 f9 ff ff       	call   80102efa <cpunum>
801035d9:	89 c2                	mov    %eax,%edx
801035db:	89 d0                	mov    %edx,%eax
801035dd:	01 c0                	add    %eax,%eax
801035df:	01 d0                	add    %edx,%eax
801035e1:	c1 e0 06             	shl    $0x6,%eax
801035e4:	05 40 f9 10 80       	add    $0x8010f940,%eax
801035e9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035ec:	74 73                	je     80103661 <startothers+0xc9>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801035ee:	e8 be f5 ff ff       	call   80102bb1 <kalloc>
801035f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801035f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035f9:	83 e8 04             	sub    $0x4,%eax
801035fc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801035ff:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103605:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103607:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010360a:	83 e8 08             	sub    $0x8,%eax
8010360d:	c7 00 38 35 10 80    	movl   $0x80103538,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103613:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103616:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103619:	83 ec 0c             	sub    $0xc,%esp
8010361c:	68 00 a0 10 80       	push   $0x8010a000
80103621:	e8 23 fe ff ff       	call   80103449 <v2p>
80103626:	83 c4 10             	add    $0x10,%esp
80103629:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010362b:	83 ec 0c             	sub    $0xc,%esp
8010362e:	ff 75 f0             	pushl  -0x10(%ebp)
80103631:	e8 13 fe ff ff       	call   80103449 <v2p>
80103636:	83 c4 10             	add    $0x10,%esp
80103639:	89 c2                	mov    %eax,%edx
8010363b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010363e:	0f b6 00             	movzbl (%eax),%eax
80103641:	0f b6 c0             	movzbl %al,%eax
80103644:	83 ec 08             	sub    $0x8,%esp
80103647:	52                   	push   %edx
80103648:	50                   	push   %eax
80103649:	e8 26 f9 ff ff       	call   80102f74 <lapicstartap>
8010364e:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103651:	90                   	nop
80103652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103655:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010365b:	85 c0                	test   %eax,%eax
8010365d:	74 f3                	je     80103652 <startothers+0xba>
8010365f:	eb 01                	jmp    80103662 <startothers+0xca>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103661:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103662:	81 45 f4 c0 00 00 00 	addl   $0xc0,-0xc(%ebp)
80103669:	a1 40 ff 10 80       	mov    0x8010ff40,%eax
8010366e:	89 c2                	mov    %eax,%edx
80103670:	89 d0                	mov    %edx,%eax
80103672:	01 c0                	add    %eax,%eax
80103674:	01 d0                	add    %edx,%eax
80103676:	c1 e0 06             	shl    $0x6,%eax
80103679:	05 40 f9 10 80       	add    $0x8010f940,%eax
8010367e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103681:	0f 87 4d ff ff ff    	ja     801035d4 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103687:	90                   	nop
80103688:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010368b:	c9                   	leave  
8010368c:	c3                   	ret    

8010368d <p2v>:
8010368d:	55                   	push   %ebp
8010368e:	89 e5                	mov    %esp,%ebp
80103690:	8b 45 08             	mov    0x8(%ebp),%eax
80103693:	05 00 00 00 80       	add    $0x80000000,%eax
80103698:	5d                   	pop    %ebp
80103699:	c3                   	ret    

8010369a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010369a:	55                   	push   %ebp
8010369b:	89 e5                	mov    %esp,%ebp
8010369d:	83 ec 14             	sub    $0x14,%esp
801036a0:	8b 45 08             	mov    0x8(%ebp),%eax
801036a3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801036a7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801036ab:	89 c2                	mov    %eax,%edx
801036ad:	ec                   	in     (%dx),%al
801036ae:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801036b1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801036b5:	c9                   	leave  
801036b6:	c3                   	ret    

801036b7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801036b7:	55                   	push   %ebp
801036b8:	89 e5                	mov    %esp,%ebp
801036ba:	83 ec 08             	sub    $0x8,%esp
801036bd:	8b 55 08             	mov    0x8(%ebp),%edx
801036c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801036c3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801036c7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801036ca:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801036ce:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801036d2:	ee                   	out    %al,(%dx)
}
801036d3:	90                   	nop
801036d4:	c9                   	leave  
801036d5:	c3                   	ret    

801036d6 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801036d6:	55                   	push   %ebp
801036d7:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801036d9:	a1 64 b6 10 80       	mov    0x8010b664,%eax
801036de:	89 c2                	mov    %eax,%edx
801036e0:	b8 40 f9 10 80       	mov    $0x8010f940,%eax
801036e5:	29 c2                	sub    %eax,%edx
801036e7:	89 d0                	mov    %edx,%eax
801036e9:	c1 f8 06             	sar    $0x6,%eax
801036ec:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}
801036f2:	5d                   	pop    %ebp
801036f3:	c3                   	ret    

801036f4 <sum>:

static uchar
sum(uchar *addr, int len)
{
801036f4:	55                   	push   %ebp
801036f5:	89 e5                	mov    %esp,%ebp
801036f7:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801036fa:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103701:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103708:	eb 15                	jmp    8010371f <sum+0x2b>
    sum += addr[i];
8010370a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010370d:	8b 45 08             	mov    0x8(%ebp),%eax
80103710:	01 d0                	add    %edx,%eax
80103712:	0f b6 00             	movzbl (%eax),%eax
80103715:	0f b6 c0             	movzbl %al,%eax
80103718:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
8010371b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010371f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103722:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103725:	7c e3                	jl     8010370a <sum+0x16>
    sum += addr[i];
  return sum;
80103727:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010372a:	c9                   	leave  
8010372b:	c3                   	ret    

8010372c <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
8010372c:	55                   	push   %ebp
8010372d:	89 e5                	mov    %esp,%ebp
8010372f:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103732:	ff 75 08             	pushl  0x8(%ebp)
80103735:	e8 53 ff ff ff       	call   8010368d <p2v>
8010373a:	83 c4 04             	add    $0x4,%esp
8010373d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103740:	8b 55 0c             	mov    0xc(%ebp),%edx
80103743:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103746:	01 d0                	add    %edx,%eax
80103748:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
8010374b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010374e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103751:	eb 36                	jmp    80103789 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103753:	83 ec 04             	sub    $0x4,%esp
80103756:	6a 04                	push   $0x4
80103758:	68 e8 83 10 80       	push   $0x801083e8
8010375d:	ff 75 f4             	pushl  -0xc(%ebp)
80103760:	e8 2b 17 00 00       	call   80104e90 <memcmp>
80103765:	83 c4 10             	add    $0x10,%esp
80103768:	85 c0                	test   %eax,%eax
8010376a:	75 19                	jne    80103785 <mpsearch1+0x59>
8010376c:	83 ec 08             	sub    $0x8,%esp
8010376f:	6a 10                	push   $0x10
80103771:	ff 75 f4             	pushl  -0xc(%ebp)
80103774:	e8 7b ff ff ff       	call   801036f4 <sum>
80103779:	83 c4 10             	add    $0x10,%esp
8010377c:	84 c0                	test   %al,%al
8010377e:	75 05                	jne    80103785 <mpsearch1+0x59>
      return (struct mp*)p;
80103780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103783:	eb 11                	jmp    80103796 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103785:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010378c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010378f:	72 c2                	jb     80103753 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103791:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103796:	c9                   	leave  
80103797:	c3                   	ret    

80103798 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103798:	55                   	push   %ebp
80103799:	89 e5                	mov    %esp,%ebp
8010379b:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
8010379e:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801037a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037a8:	83 c0 0f             	add    $0xf,%eax
801037ab:	0f b6 00             	movzbl (%eax),%eax
801037ae:	0f b6 c0             	movzbl %al,%eax
801037b1:	c1 e0 08             	shl    $0x8,%eax
801037b4:	89 c2                	mov    %eax,%edx
801037b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037b9:	83 c0 0e             	add    $0xe,%eax
801037bc:	0f b6 00             	movzbl (%eax),%eax
801037bf:	0f b6 c0             	movzbl %al,%eax
801037c2:	09 d0                	or     %edx,%eax
801037c4:	c1 e0 04             	shl    $0x4,%eax
801037c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801037ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801037ce:	74 21                	je     801037f1 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
801037d0:	83 ec 08             	sub    $0x8,%esp
801037d3:	68 00 04 00 00       	push   $0x400
801037d8:	ff 75 f0             	pushl  -0x10(%ebp)
801037db:	e8 4c ff ff ff       	call   8010372c <mpsearch1>
801037e0:	83 c4 10             	add    $0x10,%esp
801037e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801037e6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801037ea:	74 51                	je     8010383d <mpsearch+0xa5>
      return mp;
801037ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037ef:	eb 61                	jmp    80103852 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
801037f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037f4:	83 c0 14             	add    $0x14,%eax
801037f7:	0f b6 00             	movzbl (%eax),%eax
801037fa:	0f b6 c0             	movzbl %al,%eax
801037fd:	c1 e0 08             	shl    $0x8,%eax
80103800:	89 c2                	mov    %eax,%edx
80103802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103805:	83 c0 13             	add    $0x13,%eax
80103808:	0f b6 00             	movzbl (%eax),%eax
8010380b:	0f b6 c0             	movzbl %al,%eax
8010380e:	09 d0                	or     %edx,%eax
80103810:	c1 e0 0a             	shl    $0xa,%eax
80103813:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103816:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103819:	2d 00 04 00 00       	sub    $0x400,%eax
8010381e:	83 ec 08             	sub    $0x8,%esp
80103821:	68 00 04 00 00       	push   $0x400
80103826:	50                   	push   %eax
80103827:	e8 00 ff ff ff       	call   8010372c <mpsearch1>
8010382c:	83 c4 10             	add    $0x10,%esp
8010382f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103832:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103836:	74 05                	je     8010383d <mpsearch+0xa5>
      return mp;
80103838:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010383b:	eb 15                	jmp    80103852 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
8010383d:	83 ec 08             	sub    $0x8,%esp
80103840:	68 00 00 01 00       	push   $0x10000
80103845:	68 00 00 0f 00       	push   $0xf0000
8010384a:	e8 dd fe ff ff       	call   8010372c <mpsearch1>
8010384f:	83 c4 10             	add    $0x10,%esp
}
80103852:	c9                   	leave  
80103853:	c3                   	ret    

80103854 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103854:	55                   	push   %ebp
80103855:	89 e5                	mov    %esp,%ebp
80103857:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
8010385a:	e8 39 ff ff ff       	call   80103798 <mpsearch>
8010385f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103862:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103866:	74 0a                	je     80103872 <mpconfig+0x1e>
80103868:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010386b:	8b 40 04             	mov    0x4(%eax),%eax
8010386e:	85 c0                	test   %eax,%eax
80103870:	75 0a                	jne    8010387c <mpconfig+0x28>
    return 0;
80103872:	b8 00 00 00 00       	mov    $0x0,%eax
80103877:	e9 81 00 00 00       	jmp    801038fd <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
8010387c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010387f:	8b 40 04             	mov    0x4(%eax),%eax
80103882:	83 ec 0c             	sub    $0xc,%esp
80103885:	50                   	push   %eax
80103886:	e8 02 fe ff ff       	call   8010368d <p2v>
8010388b:	83 c4 10             	add    $0x10,%esp
8010388e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103891:	83 ec 04             	sub    $0x4,%esp
80103894:	6a 04                	push   $0x4
80103896:	68 ed 83 10 80       	push   $0x801083ed
8010389b:	ff 75 f0             	pushl  -0x10(%ebp)
8010389e:	e8 ed 15 00 00       	call   80104e90 <memcmp>
801038a3:	83 c4 10             	add    $0x10,%esp
801038a6:	85 c0                	test   %eax,%eax
801038a8:	74 07                	je     801038b1 <mpconfig+0x5d>
    return 0;
801038aa:	b8 00 00 00 00       	mov    $0x0,%eax
801038af:	eb 4c                	jmp    801038fd <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
801038b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038b4:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801038b8:	3c 01                	cmp    $0x1,%al
801038ba:	74 12                	je     801038ce <mpconfig+0x7a>
801038bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038bf:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801038c3:	3c 04                	cmp    $0x4,%al
801038c5:	74 07                	je     801038ce <mpconfig+0x7a>
    return 0;
801038c7:	b8 00 00 00 00       	mov    $0x0,%eax
801038cc:	eb 2f                	jmp    801038fd <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
801038ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038d1:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801038d5:	0f b7 c0             	movzwl %ax,%eax
801038d8:	83 ec 08             	sub    $0x8,%esp
801038db:	50                   	push   %eax
801038dc:	ff 75 f0             	pushl  -0x10(%ebp)
801038df:	e8 10 fe ff ff       	call   801036f4 <sum>
801038e4:	83 c4 10             	add    $0x10,%esp
801038e7:	84 c0                	test   %al,%al
801038e9:	74 07                	je     801038f2 <mpconfig+0x9e>
    return 0;
801038eb:	b8 00 00 00 00       	mov    $0x0,%eax
801038f0:	eb 0b                	jmp    801038fd <mpconfig+0xa9>
  *pmp = mp;
801038f2:	8b 45 08             	mov    0x8(%ebp),%eax
801038f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038f8:	89 10                	mov    %edx,(%eax)
  return conf;
801038fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801038fd:	c9                   	leave  
801038fe:	c3                   	ret    

801038ff <mpinit>:

void
mpinit(void)
{
801038ff:	55                   	push   %ebp
80103900:	89 e5                	mov    %esp,%ebp
80103902:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103905:	c7 05 64 b6 10 80 40 	movl   $0x8010f940,0x8010b664
8010390c:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
8010390f:	83 ec 0c             	sub    $0xc,%esp
80103912:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103915:	50                   	push   %eax
80103916:	e8 39 ff ff ff       	call   80103854 <mpconfig>
8010391b:	83 c4 10             	add    $0x10,%esp
8010391e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103921:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103925:	0f 84 9f 01 00 00    	je     80103aca <mpinit+0x1cb>
    return;
  ismp = 1;
8010392b:	c7 05 24 f9 10 80 01 	movl   $0x1,0x8010f924
80103932:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103935:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103938:	8b 40 24             	mov    0x24(%eax),%eax
8010393b:	a3 9c f8 10 80       	mov    %eax,0x8010f89c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103940:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103943:	83 c0 2c             	add    $0x2c,%eax
80103946:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103949:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010394c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103950:	0f b7 d0             	movzwl %ax,%edx
80103953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103956:	01 d0                	add    %edx,%eax
80103958:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010395b:	e9 fb 00 00 00       	jmp    80103a5b <mpinit+0x15c>
    switch(*p){
80103960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103963:	0f b6 00             	movzbl (%eax),%eax
80103966:	0f b6 c0             	movzbl %al,%eax
80103969:	83 f8 04             	cmp    $0x4,%eax
8010396c:	0f 87 c5 00 00 00    	ja     80103a37 <mpinit+0x138>
80103972:	8b 04 85 30 84 10 80 	mov    -0x7fef7bd0(,%eax,4),%eax
80103979:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
8010397b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010397e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103981:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103984:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103988:	0f b6 d0             	movzbl %al,%edx
8010398b:	a1 40 ff 10 80       	mov    0x8010ff40,%eax
80103990:	39 c2                	cmp    %eax,%edx
80103992:	74 2b                	je     801039bf <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103994:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103997:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010399b:	0f b6 d0             	movzbl %al,%edx
8010399e:	a1 40 ff 10 80       	mov    0x8010ff40,%eax
801039a3:	83 ec 04             	sub    $0x4,%esp
801039a6:	52                   	push   %edx
801039a7:	50                   	push   %eax
801039a8:	68 f2 83 10 80       	push   $0x801083f2
801039ad:	e8 14 ca ff ff       	call   801003c6 <cprintf>
801039b2:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
801039b5:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
801039bc:	00 00 00 
      }
      if(proc->flags & MPBOOT)
801039bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801039c2:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801039c6:	0f b6 c0             	movzbl %al,%eax
801039c9:	83 e0 02             	and    $0x2,%eax
801039cc:	85 c0                	test   %eax,%eax
801039ce:	74 19                	je     801039e9 <mpinit+0xea>
        bcpu = &cpus[ncpu];
801039d0:	8b 15 40 ff 10 80    	mov    0x8010ff40,%edx
801039d6:	89 d0                	mov    %edx,%eax
801039d8:	01 c0                	add    %eax,%eax
801039da:	01 d0                	add    %edx,%eax
801039dc:	c1 e0 06             	shl    $0x6,%eax
801039df:	05 40 f9 10 80       	add    $0x8010f940,%eax
801039e4:	a3 64 b6 10 80       	mov    %eax,0x8010b664
      cpus[ncpu].id = ncpu;
801039e9:	8b 15 40 ff 10 80    	mov    0x8010ff40,%edx
801039ef:	a1 40 ff 10 80       	mov    0x8010ff40,%eax
801039f4:	89 c1                	mov    %eax,%ecx
801039f6:	89 d0                	mov    %edx,%eax
801039f8:	01 c0                	add    %eax,%eax
801039fa:	01 d0                	add    %edx,%eax
801039fc:	c1 e0 06             	shl    $0x6,%eax
801039ff:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103a04:	88 08                	mov    %cl,(%eax)
      ncpu++;
80103a06:	a1 40 ff 10 80       	mov    0x8010ff40,%eax
80103a0b:	83 c0 01             	add    $0x1,%eax
80103a0e:	a3 40 ff 10 80       	mov    %eax,0x8010ff40
      p += sizeof(struct mpproc);
80103a13:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103a17:	eb 42                	jmp    80103a5b <mpinit+0x15c>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a1c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103a1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103a22:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103a26:	a2 20 f9 10 80       	mov    %al,0x8010f920
      p += sizeof(struct mpioapic);
80103a2b:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103a2f:	eb 2a                	jmp    80103a5b <mpinit+0x15c>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103a31:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103a35:	eb 24                	jmp    80103a5b <mpinit+0x15c>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a3a:	0f b6 00             	movzbl (%eax),%eax
80103a3d:	0f b6 c0             	movzbl %al,%eax
80103a40:	83 ec 08             	sub    $0x8,%esp
80103a43:	50                   	push   %eax
80103a44:	68 10 84 10 80       	push   $0x80108410
80103a49:	e8 78 c9 ff ff       	call   801003c6 <cprintf>
80103a4e:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103a51:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103a58:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a61:	0f 82 f9 fe ff ff    	jb     80103960 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103a67:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80103a6c:	85 c0                	test   %eax,%eax
80103a6e:	75 1d                	jne    80103a8d <mpinit+0x18e>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103a70:	c7 05 40 ff 10 80 01 	movl   $0x1,0x8010ff40
80103a77:	00 00 00 
    lapic = 0;
80103a7a:	c7 05 9c f8 10 80 00 	movl   $0x0,0x8010f89c
80103a81:	00 00 00 
    ioapicid = 0;
80103a84:	c6 05 20 f9 10 80 00 	movb   $0x0,0x8010f920
    return;
80103a8b:	eb 3e                	jmp    80103acb <mpinit+0x1cc>
  }

  if(mp->imcrp){
80103a8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a90:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103a94:	84 c0                	test   %al,%al
80103a96:	74 33                	je     80103acb <mpinit+0x1cc>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103a98:	83 ec 08             	sub    $0x8,%esp
80103a9b:	6a 70                	push   $0x70
80103a9d:	6a 22                	push   $0x22
80103a9f:	e8 13 fc ff ff       	call   801036b7 <outb>
80103aa4:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103aa7:	83 ec 0c             	sub    $0xc,%esp
80103aaa:	6a 23                	push   $0x23
80103aac:	e8 e9 fb ff ff       	call   8010369a <inb>
80103ab1:	83 c4 10             	add    $0x10,%esp
80103ab4:	83 c8 01             	or     $0x1,%eax
80103ab7:	0f b6 c0             	movzbl %al,%eax
80103aba:	83 ec 08             	sub    $0x8,%esp
80103abd:	50                   	push   %eax
80103abe:	6a 23                	push   $0x23
80103ac0:	e8 f2 fb ff ff       	call   801036b7 <outb>
80103ac5:	83 c4 10             	add    $0x10,%esp
80103ac8:	eb 01                	jmp    80103acb <mpinit+0x1cc>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103aca:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103acb:	c9                   	leave  
80103acc:	c3                   	ret    

80103acd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103acd:	55                   	push   %ebp
80103ace:	89 e5                	mov    %esp,%ebp
80103ad0:	83 ec 08             	sub    $0x8,%esp
80103ad3:	8b 55 08             	mov    0x8(%ebp),%edx
80103ad6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ad9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103add:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ae0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ae4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ae8:	ee                   	out    %al,(%dx)
}
80103ae9:	90                   	nop
80103aea:	c9                   	leave  
80103aeb:	c3                   	ret    

80103aec <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103aec:	55                   	push   %ebp
80103aed:	89 e5                	mov    %esp,%ebp
80103aef:	83 ec 04             	sub    $0x4,%esp
80103af2:	8b 45 08             	mov    0x8(%ebp),%eax
80103af5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103af9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103afd:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103b03:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103b07:	0f b6 c0             	movzbl %al,%eax
80103b0a:	50                   	push   %eax
80103b0b:	6a 21                	push   $0x21
80103b0d:	e8 bb ff ff ff       	call   80103acd <outb>
80103b12:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103b15:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103b19:	66 c1 e8 08          	shr    $0x8,%ax
80103b1d:	0f b6 c0             	movzbl %al,%eax
80103b20:	50                   	push   %eax
80103b21:	68 a1 00 00 00       	push   $0xa1
80103b26:	e8 a2 ff ff ff       	call   80103acd <outb>
80103b2b:	83 c4 08             	add    $0x8,%esp
}
80103b2e:	90                   	nop
80103b2f:	c9                   	leave  
80103b30:	c3                   	ret    

80103b31 <picenable>:

void
picenable(int irq)
{
80103b31:	55                   	push   %ebp
80103b32:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103b34:	8b 45 08             	mov    0x8(%ebp),%eax
80103b37:	ba 01 00 00 00       	mov    $0x1,%edx
80103b3c:	89 c1                	mov    %eax,%ecx
80103b3e:	d3 e2                	shl    %cl,%edx
80103b40:	89 d0                	mov    %edx,%eax
80103b42:	f7 d0                	not    %eax
80103b44:	89 c2                	mov    %eax,%edx
80103b46:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103b4d:	21 d0                	and    %edx,%eax
80103b4f:	0f b7 c0             	movzwl %ax,%eax
80103b52:	50                   	push   %eax
80103b53:	e8 94 ff ff ff       	call   80103aec <picsetmask>
80103b58:	83 c4 04             	add    $0x4,%esp
}
80103b5b:	90                   	nop
80103b5c:	c9                   	leave  
80103b5d:	c3                   	ret    

80103b5e <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103b5e:	55                   	push   %ebp
80103b5f:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103b61:	68 ff 00 00 00       	push   $0xff
80103b66:	6a 21                	push   $0x21
80103b68:	e8 60 ff ff ff       	call   80103acd <outb>
80103b6d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103b70:	68 ff 00 00 00       	push   $0xff
80103b75:	68 a1 00 00 00       	push   $0xa1
80103b7a:	e8 4e ff ff ff       	call   80103acd <outb>
80103b7f:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103b82:	6a 11                	push   $0x11
80103b84:	6a 20                	push   $0x20
80103b86:	e8 42 ff ff ff       	call   80103acd <outb>
80103b8b:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103b8e:	6a 20                	push   $0x20
80103b90:	6a 21                	push   $0x21
80103b92:	e8 36 ff ff ff       	call   80103acd <outb>
80103b97:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103b9a:	6a 04                	push   $0x4
80103b9c:	6a 21                	push   $0x21
80103b9e:	e8 2a ff ff ff       	call   80103acd <outb>
80103ba3:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103ba6:	6a 03                	push   $0x3
80103ba8:	6a 21                	push   $0x21
80103baa:	e8 1e ff ff ff       	call   80103acd <outb>
80103baf:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103bb2:	6a 11                	push   $0x11
80103bb4:	68 a0 00 00 00       	push   $0xa0
80103bb9:	e8 0f ff ff ff       	call   80103acd <outb>
80103bbe:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103bc1:	6a 28                	push   $0x28
80103bc3:	68 a1 00 00 00       	push   $0xa1
80103bc8:	e8 00 ff ff ff       	call   80103acd <outb>
80103bcd:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103bd0:	6a 02                	push   $0x2
80103bd2:	68 a1 00 00 00       	push   $0xa1
80103bd7:	e8 f1 fe ff ff       	call   80103acd <outb>
80103bdc:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103bdf:	6a 03                	push   $0x3
80103be1:	68 a1 00 00 00       	push   $0xa1
80103be6:	e8 e2 fe ff ff       	call   80103acd <outb>
80103beb:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103bee:	6a 68                	push   $0x68
80103bf0:	6a 20                	push   $0x20
80103bf2:	e8 d6 fe ff ff       	call   80103acd <outb>
80103bf7:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103bfa:	6a 0a                	push   $0xa
80103bfc:	6a 20                	push   $0x20
80103bfe:	e8 ca fe ff ff       	call   80103acd <outb>
80103c03:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80103c06:	6a 68                	push   $0x68
80103c08:	68 a0 00 00 00       	push   $0xa0
80103c0d:	e8 bb fe ff ff       	call   80103acd <outb>
80103c12:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80103c15:	6a 0a                	push   $0xa
80103c17:	68 a0 00 00 00       	push   $0xa0
80103c1c:	e8 ac fe ff ff       	call   80103acd <outb>
80103c21:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80103c24:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103c2b:	66 83 f8 ff          	cmp    $0xffff,%ax
80103c2f:	74 13                	je     80103c44 <picinit+0xe6>
    picsetmask(irqmask);
80103c31:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103c38:	0f b7 c0             	movzwl %ax,%eax
80103c3b:	50                   	push   %eax
80103c3c:	e8 ab fe ff ff       	call   80103aec <picsetmask>
80103c41:	83 c4 04             	add    $0x4,%esp
}
80103c44:	90                   	nop
80103c45:	c9                   	leave  
80103c46:	c3                   	ret    

80103c47 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103c47:	55                   	push   %ebp
80103c48:	89 e5                	mov    %esp,%ebp
80103c4a:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103c4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103c54:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c57:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c60:	8b 10                	mov    (%eax),%edx
80103c62:	8b 45 08             	mov    0x8(%ebp),%eax
80103c65:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103c67:	e8 f8 d2 ff ff       	call   80100f64 <filealloc>
80103c6c:	89 c2                	mov    %eax,%edx
80103c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103c71:	89 10                	mov    %edx,(%eax)
80103c73:	8b 45 08             	mov    0x8(%ebp),%eax
80103c76:	8b 00                	mov    (%eax),%eax
80103c78:	85 c0                	test   %eax,%eax
80103c7a:	0f 84 cb 00 00 00    	je     80103d4b <pipealloc+0x104>
80103c80:	e8 df d2 ff ff       	call   80100f64 <filealloc>
80103c85:	89 c2                	mov    %eax,%edx
80103c87:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c8a:	89 10                	mov    %edx,(%eax)
80103c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c8f:	8b 00                	mov    (%eax),%eax
80103c91:	85 c0                	test   %eax,%eax
80103c93:	0f 84 b2 00 00 00    	je     80103d4b <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103c99:	e8 13 ef ff ff       	call   80102bb1 <kalloc>
80103c9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ca1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ca5:	0f 84 9f 00 00 00    	je     80103d4a <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80103cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cae:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103cb5:	00 00 00 
  p->writeopen = 1;
80103cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cbb:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103cc2:	00 00 00 
  p->nwrite = 0;
80103cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc8:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ccf:	00 00 00 
  p->nread = 0;
80103cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd5:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103cdc:	00 00 00 
  initlock(&p->lock, "pipe");
80103cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce2:	83 ec 08             	sub    $0x8,%esp
80103ce5:	68 44 84 10 80       	push   $0x80108444
80103cea:	50                   	push   %eax
80103ceb:	e8 b4 0e 00 00       	call   80104ba4 <initlock>
80103cf0:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf6:	8b 00                	mov    (%eax),%eax
80103cf8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80103d01:	8b 00                	mov    (%eax),%eax
80103d03:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103d07:	8b 45 08             	mov    0x8(%ebp),%eax
80103d0a:	8b 00                	mov    (%eax),%eax
80103d0c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103d10:	8b 45 08             	mov    0x8(%ebp),%eax
80103d13:	8b 00                	mov    (%eax),%eax
80103d15:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d18:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d1e:	8b 00                	mov    (%eax),%eax
80103d20:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103d26:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d29:	8b 00                	mov    (%eax),%eax
80103d2b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d32:	8b 00                	mov    (%eax),%eax
80103d34:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103d38:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d3b:	8b 00                	mov    (%eax),%eax
80103d3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d40:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103d43:	b8 00 00 00 00       	mov    $0x0,%eax
80103d48:	eb 4e                	jmp    80103d98 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80103d4a:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80103d4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d4f:	74 0e                	je     80103d5f <pipealloc+0x118>
    kfree((char*)p);
80103d51:	83 ec 0c             	sub    $0xc,%esp
80103d54:	ff 75 f4             	pushl  -0xc(%ebp)
80103d57:	e8 b8 ed ff ff       	call   80102b14 <kfree>
80103d5c:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103d5f:	8b 45 08             	mov    0x8(%ebp),%eax
80103d62:	8b 00                	mov    (%eax),%eax
80103d64:	85 c0                	test   %eax,%eax
80103d66:	74 11                	je     80103d79 <pipealloc+0x132>
    fileclose(*f0);
80103d68:	8b 45 08             	mov    0x8(%ebp),%eax
80103d6b:	8b 00                	mov    (%eax),%eax
80103d6d:	83 ec 0c             	sub    $0xc,%esp
80103d70:	50                   	push   %eax
80103d71:	e8 ac d2 ff ff       	call   80101022 <fileclose>
80103d76:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103d79:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d7c:	8b 00                	mov    (%eax),%eax
80103d7e:	85 c0                	test   %eax,%eax
80103d80:	74 11                	je     80103d93 <pipealloc+0x14c>
    fileclose(*f1);
80103d82:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d85:	8b 00                	mov    (%eax),%eax
80103d87:	83 ec 0c             	sub    $0xc,%esp
80103d8a:	50                   	push   %eax
80103d8b:	e8 92 d2 ff ff       	call   80101022 <fileclose>
80103d90:	83 c4 10             	add    $0x10,%esp
  return -1;
80103d93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103d98:	c9                   	leave  
80103d99:	c3                   	ret    

80103d9a <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103d9a:	55                   	push   %ebp
80103d9b:	89 e5                	mov    %esp,%ebp
80103d9d:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103da0:	8b 45 08             	mov    0x8(%ebp),%eax
80103da3:	83 ec 0c             	sub    $0xc,%esp
80103da6:	50                   	push   %eax
80103da7:	e8 1a 0e 00 00       	call   80104bc6 <acquire>
80103dac:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103daf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103db3:	74 23                	je     80103dd8 <pipeclose+0x3e>
    p->writeopen = 0;
80103db5:	8b 45 08             	mov    0x8(%ebp),%eax
80103db8:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103dbf:	00 00 00 
    wakeup(&p->nread);
80103dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc5:	05 34 02 00 00       	add    $0x234,%eax
80103dca:	83 ec 0c             	sub    $0xc,%esp
80103dcd:	50                   	push   %eax
80103dce:	e8 e5 0b 00 00       	call   801049b8 <wakeup>
80103dd3:	83 c4 10             	add    $0x10,%esp
80103dd6:	eb 21                	jmp    80103df9 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103ddb:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103de2:	00 00 00 
    wakeup(&p->nwrite);
80103de5:	8b 45 08             	mov    0x8(%ebp),%eax
80103de8:	05 38 02 00 00       	add    $0x238,%eax
80103ded:	83 ec 0c             	sub    $0xc,%esp
80103df0:	50                   	push   %eax
80103df1:	e8 c2 0b 00 00       	call   801049b8 <wakeup>
80103df6:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103df9:	8b 45 08             	mov    0x8(%ebp),%eax
80103dfc:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103e02:	85 c0                	test   %eax,%eax
80103e04:	75 2c                	jne    80103e32 <pipeclose+0x98>
80103e06:	8b 45 08             	mov    0x8(%ebp),%eax
80103e09:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103e0f:	85 c0                	test   %eax,%eax
80103e11:	75 1f                	jne    80103e32 <pipeclose+0x98>
    release(&p->lock);
80103e13:	8b 45 08             	mov    0x8(%ebp),%eax
80103e16:	83 ec 0c             	sub    $0xc,%esp
80103e19:	50                   	push   %eax
80103e1a:	e8 0e 0e 00 00       	call   80104c2d <release>
80103e1f:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103e22:	83 ec 0c             	sub    $0xc,%esp
80103e25:	ff 75 08             	pushl  0x8(%ebp)
80103e28:	e8 e7 ec ff ff       	call   80102b14 <kfree>
80103e2d:	83 c4 10             	add    $0x10,%esp
80103e30:	eb 0f                	jmp    80103e41 <pipeclose+0xa7>
  } else
    release(&p->lock);
80103e32:	8b 45 08             	mov    0x8(%ebp),%eax
80103e35:	83 ec 0c             	sub    $0xc,%esp
80103e38:	50                   	push   %eax
80103e39:	e8 ef 0d 00 00       	call   80104c2d <release>
80103e3e:	83 c4 10             	add    $0x10,%esp
}
80103e41:	90                   	nop
80103e42:	c9                   	leave  
80103e43:	c3                   	ret    

80103e44 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103e44:	55                   	push   %ebp
80103e45:	89 e5                	mov    %esp,%ebp
80103e47:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103e4a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e4d:	83 ec 0c             	sub    $0xc,%esp
80103e50:	50                   	push   %eax
80103e51:	e8 70 0d 00 00       	call   80104bc6 <acquire>
80103e56:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103e59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103e60:	e9 ad 00 00 00       	jmp    80103f12 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80103e65:	8b 45 08             	mov    0x8(%ebp),%eax
80103e68:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103e6e:	85 c0                	test   %eax,%eax
80103e70:	74 0d                	je     80103e7f <pipewrite+0x3b>
80103e72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e78:	8b 40 24             	mov    0x24(%eax),%eax
80103e7b:	85 c0                	test   %eax,%eax
80103e7d:	74 19                	je     80103e98 <pipewrite+0x54>
        release(&p->lock);
80103e7f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e82:	83 ec 0c             	sub    $0xc,%esp
80103e85:	50                   	push   %eax
80103e86:	e8 a2 0d 00 00       	call   80104c2d <release>
80103e8b:	83 c4 10             	add    $0x10,%esp
        return -1;
80103e8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e93:	e9 a8 00 00 00       	jmp    80103f40 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80103e98:	8b 45 08             	mov    0x8(%ebp),%eax
80103e9b:	05 34 02 00 00       	add    $0x234,%eax
80103ea0:	83 ec 0c             	sub    $0xc,%esp
80103ea3:	50                   	push   %eax
80103ea4:	e8 0f 0b 00 00       	call   801049b8 <wakeup>
80103ea9:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103eac:	8b 45 08             	mov    0x8(%ebp),%eax
80103eaf:	8b 55 08             	mov    0x8(%ebp),%edx
80103eb2:	81 c2 38 02 00 00    	add    $0x238,%edx
80103eb8:	83 ec 08             	sub    $0x8,%esp
80103ebb:	50                   	push   %eax
80103ebc:	52                   	push   %edx
80103ebd:	e8 0b 0a 00 00       	call   801048cd <sleep>
80103ec2:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103ec5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec8:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103ece:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed1:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103ed7:	05 00 02 00 00       	add    $0x200,%eax
80103edc:	39 c2                	cmp    %eax,%edx
80103ede:	74 85                	je     80103e65 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103ee9:	8d 48 01             	lea    0x1(%eax),%ecx
80103eec:	8b 55 08             	mov    0x8(%ebp),%edx
80103eef:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103ef5:	25 ff 01 00 00       	and    $0x1ff,%eax
80103efa:	89 c1                	mov    %eax,%ecx
80103efc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103eff:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f02:	01 d0                	add    %edx,%eax
80103f04:	0f b6 10             	movzbl (%eax),%edx
80103f07:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0a:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80103f0e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f15:	3b 45 10             	cmp    0x10(%ebp),%eax
80103f18:	7c ab                	jl     80103ec5 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1d:	05 34 02 00 00       	add    $0x234,%eax
80103f22:	83 ec 0c             	sub    $0xc,%esp
80103f25:	50                   	push   %eax
80103f26:	e8 8d 0a 00 00       	call   801049b8 <wakeup>
80103f2b:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f31:	83 ec 0c             	sub    $0xc,%esp
80103f34:	50                   	push   %eax
80103f35:	e8 f3 0c 00 00       	call   80104c2d <release>
80103f3a:	83 c4 10             	add    $0x10,%esp
  return n;
80103f3d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103f40:	c9                   	leave  
80103f41:	c3                   	ret    

80103f42 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103f42:	55                   	push   %ebp
80103f43:	89 e5                	mov    %esp,%ebp
80103f45:	53                   	push   %ebx
80103f46:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103f49:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4c:	83 ec 0c             	sub    $0xc,%esp
80103f4f:	50                   	push   %eax
80103f50:	e8 71 0c 00 00       	call   80104bc6 <acquire>
80103f55:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f58:	eb 3f                	jmp    80103f99 <piperead+0x57>
    if(proc->killed){
80103f5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103f60:	8b 40 24             	mov    0x24(%eax),%eax
80103f63:	85 c0                	test   %eax,%eax
80103f65:	74 19                	je     80103f80 <piperead+0x3e>
      release(&p->lock);
80103f67:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6a:	83 ec 0c             	sub    $0xc,%esp
80103f6d:	50                   	push   %eax
80103f6e:	e8 ba 0c 00 00       	call   80104c2d <release>
80103f73:	83 c4 10             	add    $0x10,%esp
      return -1;
80103f76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f7b:	e9 bf 00 00 00       	jmp    8010403f <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103f80:	8b 45 08             	mov    0x8(%ebp),%eax
80103f83:	8b 55 08             	mov    0x8(%ebp),%edx
80103f86:	81 c2 34 02 00 00    	add    $0x234,%edx
80103f8c:	83 ec 08             	sub    $0x8,%esp
80103f8f:	50                   	push   %eax
80103f90:	52                   	push   %edx
80103f91:	e8 37 09 00 00       	call   801048cd <sleep>
80103f96:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f99:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9c:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa5:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103fab:	39 c2                	cmp    %eax,%edx
80103fad:	75 0d                	jne    80103fbc <piperead+0x7a>
80103faf:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb2:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103fb8:	85 c0                	test   %eax,%eax
80103fba:	75 9e                	jne    80103f5a <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103fbc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103fc3:	eb 49                	jmp    8010400e <piperead+0xcc>
    if(p->nread == p->nwrite)
80103fc5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc8:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103fce:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd1:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103fd7:	39 c2                	cmp    %eax,%edx
80103fd9:	74 3d                	je     80104018 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103fdb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fde:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe1:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103fed:	8d 48 01             	lea    0x1(%eax),%ecx
80103ff0:	8b 55 08             	mov    0x8(%ebp),%edx
80103ff3:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103ff9:	25 ff 01 00 00       	and    $0x1ff,%eax
80103ffe:	89 c2                	mov    %eax,%edx
80104000:	8b 45 08             	mov    0x8(%ebp),%eax
80104003:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104008:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010400a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010400e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104011:	3b 45 10             	cmp    0x10(%ebp),%eax
80104014:	7c af                	jl     80103fc5 <piperead+0x83>
80104016:	eb 01                	jmp    80104019 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104018:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104019:	8b 45 08             	mov    0x8(%ebp),%eax
8010401c:	05 38 02 00 00       	add    $0x238,%eax
80104021:	83 ec 0c             	sub    $0xc,%esp
80104024:	50                   	push   %eax
80104025:	e8 8e 09 00 00       	call   801049b8 <wakeup>
8010402a:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010402d:	8b 45 08             	mov    0x8(%ebp),%eax
80104030:	83 ec 0c             	sub    $0xc,%esp
80104033:	50                   	push   %eax
80104034:	e8 f4 0b 00 00       	call   80104c2d <release>
80104039:	83 c4 10             	add    $0x10,%esp
  return i;
8010403c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010403f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104042:	c9                   	leave  
80104043:	c3                   	ret    

80104044 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104044:	55                   	push   %ebp
80104045:	89 e5                	mov    %esp,%ebp
80104047:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010404a:	9c                   	pushf  
8010404b:	58                   	pop    %eax
8010404c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010404f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104052:	c9                   	leave  
80104053:	c3                   	ret    

80104054 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104054:	55                   	push   %ebp
80104055:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104057:	fb                   	sti    
}
80104058:	90                   	nop
80104059:	5d                   	pop    %ebp
8010405a:	c3                   	ret    

8010405b <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010405b:	55                   	push   %ebp
8010405c:	89 e5                	mov    %esp,%ebp
8010405e:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104061:	83 ec 08             	sub    $0x8,%esp
80104064:	68 49 84 10 80       	push   $0x80108449
80104069:	68 60 ff 10 80       	push   $0x8010ff60
8010406e:	e8 31 0b 00 00       	call   80104ba4 <initlock>
80104073:	83 c4 10             	add    $0x10,%esp
}
80104076:	90                   	nop
80104077:	c9                   	leave  
80104078:	c3                   	ret    

80104079 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104079:	55                   	push   %ebp
8010407a:	89 e5                	mov    %esp,%ebp
8010407c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010407f:	83 ec 0c             	sub    $0xc,%esp
80104082:	68 60 ff 10 80       	push   $0x8010ff60
80104087:	e8 3a 0b 00 00       	call   80104bc6 <acquire>
8010408c:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010408f:	c7 45 f4 94 ff 10 80 	movl   $0x8010ff94,-0xc(%ebp)
80104096:	eb 0e                	jmp    801040a6 <allocproc+0x2d>
    if(p->state == UNUSED)
80104098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409b:	8b 40 0c             	mov    0xc(%eax),%eax
8010409e:	85 c0                	test   %eax,%eax
801040a0:	74 27                	je     801040c9 <allocproc+0x50>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801040a2:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801040a6:	81 7d f4 94 1e 11 80 	cmpl   $0x80111e94,-0xc(%ebp)
801040ad:	72 e9                	jb     80104098 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801040af:	83 ec 0c             	sub    $0xc,%esp
801040b2:	68 60 ff 10 80       	push   $0x8010ff60
801040b7:	e8 71 0b 00 00       	call   80104c2d <release>
801040bc:	83 c4 10             	add    $0x10,%esp
  return 0;
801040bf:	b8 00 00 00 00       	mov    $0x0,%eax
801040c4:	e9 b4 00 00 00       	jmp    8010417d <allocproc+0x104>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801040c9:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801040ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040cd:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801040d4:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801040d9:	8d 50 01             	lea    0x1(%eax),%edx
801040dc:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
801040e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040e5:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801040e8:	83 ec 0c             	sub    $0xc,%esp
801040eb:	68 60 ff 10 80       	push   $0x8010ff60
801040f0:	e8 38 0b 00 00       	call   80104c2d <release>
801040f5:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801040f8:	e8 b4 ea ff ff       	call   80102bb1 <kalloc>
801040fd:	89 c2                	mov    %eax,%edx
801040ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104102:	89 50 08             	mov    %edx,0x8(%eax)
80104105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104108:	8b 40 08             	mov    0x8(%eax),%eax
8010410b:	85 c0                	test   %eax,%eax
8010410d:	75 11                	jne    80104120 <allocproc+0xa7>
    p->state = UNUSED;
8010410f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104112:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104119:	b8 00 00 00 00       	mov    $0x0,%eax
8010411e:	eb 5d                	jmp    8010417d <allocproc+0x104>
  }
  sp = p->kstack + KSTACKSIZE;
80104120:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104123:	8b 40 08             	mov    0x8(%eax),%eax
80104126:	05 00 10 00 00       	add    $0x1000,%eax
8010412b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010412e:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104135:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104138:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010413b:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010413f:	ba 95 62 10 80       	mov    $0x80106295,%edx
80104144:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104147:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104149:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010414d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104150:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104153:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104159:	8b 40 1c             	mov    0x1c(%eax),%eax
8010415c:	83 ec 04             	sub    $0x4,%esp
8010415f:	6a 14                	push   $0x14
80104161:	6a 00                	push   $0x0
80104163:	50                   	push   %eax
80104164:	e8 c0 0c 00 00       	call   80104e29 <memset>
80104169:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010416c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104172:	ba 9c 48 10 80       	mov    $0x8010489c,%edx
80104177:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010417a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010417d:	c9                   	leave  
8010417e:	c3                   	ret    

8010417f <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010417f:	55                   	push   %ebp
80104180:	89 e5                	mov    %esp,%ebp
80104182:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104185:	e8 ef fe ff ff       	call   80104079 <allocproc>
8010418a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010418d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104190:	a3 68 b6 10 80       	mov    %eax,0x8010b668
  if((p->pgdir = setupkvm()) == 0)
80104195:	e8 c5 37 00 00       	call   8010795f <setupkvm>
8010419a:	89 c2                	mov    %eax,%edx
8010419c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419f:	89 50 04             	mov    %edx,0x4(%eax)
801041a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a5:	8b 40 04             	mov    0x4(%eax),%eax
801041a8:	85 c0                	test   %eax,%eax
801041aa:	75 0d                	jne    801041b9 <userinit+0x3a>
    panic("userinit: out of memory?");
801041ac:	83 ec 0c             	sub    $0xc,%esp
801041af:	68 50 84 10 80       	push   $0x80108450
801041b4:	e8 ad c3 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801041b9:	ba 2c 00 00 00       	mov    $0x2c,%edx
801041be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c1:	8b 40 04             	mov    0x4(%eax),%eax
801041c4:	83 ec 04             	sub    $0x4,%esp
801041c7:	52                   	push   %edx
801041c8:	68 00 b5 10 80       	push   $0x8010b500
801041cd:	50                   	push   %eax
801041ce:	e8 e6 39 00 00       	call   80107bb9 <inituvm>
801041d3:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801041d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d9:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801041df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e2:	8b 40 18             	mov    0x18(%eax),%eax
801041e5:	83 ec 04             	sub    $0x4,%esp
801041e8:	6a 4c                	push   $0x4c
801041ea:	6a 00                	push   $0x0
801041ec:	50                   	push   %eax
801041ed:	e8 37 0c 00 00       	call   80104e29 <memset>
801041f2:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801041f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f8:	8b 40 18             	mov    0x18(%eax),%eax
801041fb:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104201:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104204:	8b 40 18             	mov    0x18(%eax),%eax
80104207:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010420d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104210:	8b 40 18             	mov    0x18(%eax),%eax
80104213:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104216:	8b 52 18             	mov    0x18(%edx),%edx
80104219:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010421d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104224:	8b 40 18             	mov    0x18(%eax),%eax
80104227:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010422a:	8b 52 18             	mov    0x18(%edx),%edx
8010422d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104231:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104238:	8b 40 18             	mov    0x18(%eax),%eax
8010423b:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104242:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104245:	8b 40 18             	mov    0x18(%eax),%eax
80104248:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010424f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104252:	8b 40 18             	mov    0x18(%eax),%eax
80104255:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010425c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425f:	83 c0 6c             	add    $0x6c,%eax
80104262:	83 ec 04             	sub    $0x4,%esp
80104265:	6a 10                	push   $0x10
80104267:	68 69 84 10 80       	push   $0x80108469
8010426c:	50                   	push   %eax
8010426d:	e8 ba 0d 00 00       	call   8010502c <safestrcpy>
80104272:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104275:	83 ec 0c             	sub    $0xc,%esp
80104278:	68 72 84 10 80       	push   $0x80108472
8010427d:	e8 2d e2 ff ff       	call   801024af <namei>
80104282:	83 c4 10             	add    $0x10,%esp
80104285:	89 c2                	mov    %eax,%edx
80104287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010428a:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
8010428d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104290:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104297:	90                   	nop
80104298:	c9                   	leave  
80104299:	c3                   	ret    

8010429a <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010429a:	55                   	push   %ebp
8010429b:	89 e5                	mov    %esp,%ebp
8010429d:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801042a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042a6:	8b 00                	mov    (%eax),%eax
801042a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801042ab:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801042af:	7e 31                	jle    801042e2 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801042b1:	8b 55 08             	mov    0x8(%ebp),%edx
801042b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b7:	01 c2                	add    %eax,%edx
801042b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042bf:	8b 40 04             	mov    0x4(%eax),%eax
801042c2:	83 ec 04             	sub    $0x4,%esp
801042c5:	52                   	push   %edx
801042c6:	ff 75 f4             	pushl  -0xc(%ebp)
801042c9:	50                   	push   %eax
801042ca:	e8 37 3a 00 00       	call   80107d06 <allocuvm>
801042cf:	83 c4 10             	add    $0x10,%esp
801042d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801042d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042d9:	75 3e                	jne    80104319 <growproc+0x7f>
      return -1;
801042db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042e0:	eb 59                	jmp    8010433b <growproc+0xa1>
  } else if(n < 0){
801042e2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801042e6:	79 31                	jns    80104319 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801042e8:	8b 55 08             	mov    0x8(%ebp),%edx
801042eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ee:	01 c2                	add    %eax,%edx
801042f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042f6:	8b 40 04             	mov    0x4(%eax),%eax
801042f9:	83 ec 04             	sub    $0x4,%esp
801042fc:	52                   	push   %edx
801042fd:	ff 75 f4             	pushl  -0xc(%ebp)
80104300:	50                   	push   %eax
80104301:	e8 c9 3a 00 00       	call   80107dcf <deallocuvm>
80104306:	83 c4 10             	add    $0x10,%esp
80104309:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010430c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104310:	75 07                	jne    80104319 <growproc+0x7f>
      return -1;
80104312:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104317:	eb 22                	jmp    8010433b <growproc+0xa1>
  }
  proc->sz = sz;
80104319:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010431f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104322:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104324:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010432a:	83 ec 0c             	sub    $0xc,%esp
8010432d:	50                   	push   %eax
8010432e:	e8 13 37 00 00       	call   80107a46 <switchuvm>
80104333:	83 c4 10             	add    $0x10,%esp
  return 0;
80104336:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010433b:	c9                   	leave  
8010433c:	c3                   	ret    

8010433d <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010433d:	55                   	push   %ebp
8010433e:	89 e5                	mov    %esp,%ebp
80104340:	57                   	push   %edi
80104341:	56                   	push   %esi
80104342:	53                   	push   %ebx
80104343:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104346:	e8 2e fd ff ff       	call   80104079 <allocproc>
8010434b:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010434e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104352:	75 0a                	jne    8010435e <fork+0x21>
    return -1;
80104354:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104359:	e9 48 01 00 00       	jmp    801044a6 <fork+0x169>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010435e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104364:	8b 10                	mov    (%eax),%edx
80104366:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010436c:	8b 40 04             	mov    0x4(%eax),%eax
8010436f:	83 ec 08             	sub    $0x8,%esp
80104372:	52                   	push   %edx
80104373:	50                   	push   %eax
80104374:	e8 f4 3b 00 00       	call   80107f6d <copyuvm>
80104379:	83 c4 10             	add    $0x10,%esp
8010437c:	89 c2                	mov    %eax,%edx
8010437e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104381:	89 50 04             	mov    %edx,0x4(%eax)
80104384:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104387:	8b 40 04             	mov    0x4(%eax),%eax
8010438a:	85 c0                	test   %eax,%eax
8010438c:	75 30                	jne    801043be <fork+0x81>
    kfree(np->kstack);
8010438e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104391:	8b 40 08             	mov    0x8(%eax),%eax
80104394:	83 ec 0c             	sub    $0xc,%esp
80104397:	50                   	push   %eax
80104398:	e8 77 e7 ff ff       	call   80102b14 <kfree>
8010439d:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801043a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043a3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801043aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043ad:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801043b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043b9:	e9 e8 00 00 00       	jmp    801044a6 <fork+0x169>
  }
  np->sz = proc->sz;
801043be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043c4:	8b 10                	mov    (%eax),%edx
801043c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043c9:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801043cb:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801043d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043d5:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801043d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043db:	8b 50 18             	mov    0x18(%eax),%edx
801043de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043e4:	8b 40 18             	mov    0x18(%eax),%eax
801043e7:	89 c3                	mov    %eax,%ebx
801043e9:	b8 13 00 00 00       	mov    $0x13,%eax
801043ee:	89 d7                	mov    %edx,%edi
801043f0:	89 de                	mov    %ebx,%esi
801043f2:	89 c1                	mov    %eax,%ecx
801043f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801043f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043f9:	8b 40 18             	mov    0x18(%eax),%eax
801043fc:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104403:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010440a:	eb 43                	jmp    8010444f <fork+0x112>
    if(proc->ofile[i])
8010440c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104412:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104415:	83 c2 08             	add    $0x8,%edx
80104418:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010441c:	85 c0                	test   %eax,%eax
8010441e:	74 2b                	je     8010444b <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80104420:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104426:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104429:	83 c2 08             	add    $0x8,%edx
8010442c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104430:	83 ec 0c             	sub    $0xc,%esp
80104433:	50                   	push   %eax
80104434:	e8 98 cb ff ff       	call   80100fd1 <filedup>
80104439:	83 c4 10             	add    $0x10,%esp
8010443c:	89 c1                	mov    %eax,%ecx
8010443e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104441:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104444:	83 c2 08             	add    $0x8,%edx
80104447:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010444b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010444f:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104453:	7e b7                	jle    8010440c <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104455:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010445b:	8b 40 68             	mov    0x68(%eax),%eax
8010445e:	83 ec 0c             	sub    $0xc,%esp
80104461:	50                   	push   %eax
80104462:	e8 56 d4 ff ff       	call   801018bd <idup>
80104467:	83 c4 10             	add    $0x10,%esp
8010446a:	89 c2                	mov    %eax,%edx
8010446c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010446f:	89 50 68             	mov    %edx,0x68(%eax)
 
  pid = np->pid;
80104472:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104475:	8b 40 10             	mov    0x10(%eax),%eax
80104478:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
8010447b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010447e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104485:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010448b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010448e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104491:	83 c0 6c             	add    $0x6c,%eax
80104494:	83 ec 04             	sub    $0x4,%esp
80104497:	6a 10                	push   $0x10
80104499:	52                   	push   %edx
8010449a:	50                   	push   %eax
8010449b:	e8 8c 0b 00 00       	call   8010502c <safestrcpy>
801044a0:	83 c4 10             	add    $0x10,%esp
  return pid;
801044a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801044a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801044a9:	5b                   	pop    %ebx
801044aa:	5e                   	pop    %esi
801044ab:	5f                   	pop    %edi
801044ac:	5d                   	pop    %ebp
801044ad:	c3                   	ret    

801044ae <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801044ae:	55                   	push   %ebp
801044af:	89 e5                	mov    %esp,%ebp
801044b1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801044b4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801044bb:	a1 68 b6 10 80       	mov    0x8010b668,%eax
801044c0:	39 c2                	cmp    %eax,%edx
801044c2:	75 0d                	jne    801044d1 <exit+0x23>
    panic("init exiting");
801044c4:	83 ec 0c             	sub    $0xc,%esp
801044c7:	68 74 84 10 80       	push   $0x80108474
801044cc:	e8 95 c0 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801044d1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801044d8:	eb 48                	jmp    80104522 <exit+0x74>
    if(proc->ofile[fd]){
801044da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044e3:	83 c2 08             	add    $0x8,%edx
801044e6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801044ea:	85 c0                	test   %eax,%eax
801044ec:	74 30                	je     8010451e <exit+0x70>
      fileclose(proc->ofile[fd]);
801044ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044f7:	83 c2 08             	add    $0x8,%edx
801044fa:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801044fe:	83 ec 0c             	sub    $0xc,%esp
80104501:	50                   	push   %eax
80104502:	e8 1b cb ff ff       	call   80101022 <fileclose>
80104507:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
8010450a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104510:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104513:	83 c2 08             	add    $0x8,%edx
80104516:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010451d:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010451e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104522:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104526:	7e b2                	jle    801044da <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
80104528:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010452e:	8b 40 68             	mov    0x68(%eax),%eax
80104531:	83 ec 0c             	sub    $0xc,%esp
80104534:	50                   	push   %eax
80104535:	e8 87 d5 ff ff       	call   80101ac1 <iput>
8010453a:	83 c4 10             	add    $0x10,%esp
  proc->cwd = 0;
8010453d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104543:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010454a:	83 ec 0c             	sub    $0xc,%esp
8010454d:	68 60 ff 10 80       	push   $0x8010ff60
80104552:	e8 6f 06 00 00       	call   80104bc6 <acquire>
80104557:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010455a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104560:	8b 40 14             	mov    0x14(%eax),%eax
80104563:	83 ec 0c             	sub    $0xc,%esp
80104566:	50                   	push   %eax
80104567:	e8 0d 04 00 00       	call   80104979 <wakeup1>
8010456c:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010456f:	c7 45 f4 94 ff 10 80 	movl   $0x8010ff94,-0xc(%ebp)
80104576:	eb 3c                	jmp    801045b4 <exit+0x106>
    if(p->parent == proc){
80104578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457b:	8b 50 14             	mov    0x14(%eax),%edx
8010457e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104584:	39 c2                	cmp    %eax,%edx
80104586:	75 28                	jne    801045b0 <exit+0x102>
      p->parent = initproc;
80104588:	8b 15 68 b6 10 80    	mov    0x8010b668,%edx
8010458e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104591:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104597:	8b 40 0c             	mov    0xc(%eax),%eax
8010459a:	83 f8 05             	cmp    $0x5,%eax
8010459d:	75 11                	jne    801045b0 <exit+0x102>
        wakeup1(initproc);
8010459f:	a1 68 b6 10 80       	mov    0x8010b668,%eax
801045a4:	83 ec 0c             	sub    $0xc,%esp
801045a7:	50                   	push   %eax
801045a8:	e8 cc 03 00 00       	call   80104979 <wakeup1>
801045ad:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045b0:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801045b4:	81 7d f4 94 1e 11 80 	cmpl   $0x80111e94,-0xc(%ebp)
801045bb:	72 bb                	jb     80104578 <exit+0xca>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801045bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045c3:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801045ca:	e8 d6 01 00 00       	call   801047a5 <sched>
  panic("zombie exit");
801045cf:	83 ec 0c             	sub    $0xc,%esp
801045d2:	68 81 84 10 80       	push   $0x80108481
801045d7:	e8 8a bf ff ff       	call   80100566 <panic>

801045dc <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801045dc:	55                   	push   %ebp
801045dd:	89 e5                	mov    %esp,%ebp
801045df:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801045e2:	83 ec 0c             	sub    $0xc,%esp
801045e5:	68 60 ff 10 80       	push   $0x8010ff60
801045ea:	e8 d7 05 00 00       	call   80104bc6 <acquire>
801045ef:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801045f2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045f9:	c7 45 f4 94 ff 10 80 	movl   $0x8010ff94,-0xc(%ebp)
80104600:	e9 a6 00 00 00       	jmp    801046ab <wait+0xcf>
      if(p->parent != proc)
80104605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104608:	8b 50 14             	mov    0x14(%eax),%edx
8010460b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104611:	39 c2                	cmp    %eax,%edx
80104613:	0f 85 8d 00 00 00    	jne    801046a6 <wait+0xca>
        continue;
      havekids = 1;
80104619:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104623:	8b 40 0c             	mov    0xc(%eax),%eax
80104626:	83 f8 05             	cmp    $0x5,%eax
80104629:	75 7c                	jne    801046a7 <wait+0xcb>
        // Found one.
        pid = p->pid;
8010462b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462e:	8b 40 10             	mov    0x10(%eax),%eax
80104631:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104637:	8b 40 08             	mov    0x8(%eax),%eax
8010463a:	83 ec 0c             	sub    $0xc,%esp
8010463d:	50                   	push   %eax
8010463e:	e8 d1 e4 ff ff       	call   80102b14 <kfree>
80104643:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104646:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104649:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104653:	8b 40 04             	mov    0x4(%eax),%eax
80104656:	83 ec 0c             	sub    $0xc,%esp
80104659:	50                   	push   %eax
8010465a:	e8 2d 38 00 00       	call   80107e8c <freevm>
8010465f:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104665:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
8010466c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104679:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104683:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468a:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104691:	83 ec 0c             	sub    $0xc,%esp
80104694:	68 60 ff 10 80       	push   $0x8010ff60
80104699:	e8 8f 05 00 00       	call   80104c2d <release>
8010469e:	83 c4 10             	add    $0x10,%esp
        return pid;
801046a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046a4:	eb 58                	jmp    801046fe <wait+0x122>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801046a6:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046a7:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801046ab:	81 7d f4 94 1e 11 80 	cmpl   $0x80111e94,-0xc(%ebp)
801046b2:	0f 82 4d ff ff ff    	jb     80104605 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801046b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801046bc:	74 0d                	je     801046cb <wait+0xef>
801046be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046c4:	8b 40 24             	mov    0x24(%eax),%eax
801046c7:	85 c0                	test   %eax,%eax
801046c9:	74 17                	je     801046e2 <wait+0x106>
      release(&ptable.lock);
801046cb:	83 ec 0c             	sub    $0xc,%esp
801046ce:	68 60 ff 10 80       	push   $0x8010ff60
801046d3:	e8 55 05 00 00       	call   80104c2d <release>
801046d8:	83 c4 10             	add    $0x10,%esp
      return -1;
801046db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046e0:	eb 1c                	jmp    801046fe <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801046e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e8:	83 ec 08             	sub    $0x8,%esp
801046eb:	68 60 ff 10 80       	push   $0x8010ff60
801046f0:	50                   	push   %eax
801046f1:	e8 d7 01 00 00       	call   801048cd <sleep>
801046f6:	83 c4 10             	add    $0x10,%esp
  }
801046f9:	e9 f4 fe ff ff       	jmp    801045f2 <wait+0x16>
}
801046fe:	c9                   	leave  
801046ff:	c3                   	ret    

80104700 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104700:	55                   	push   %ebp
80104701:	89 e5                	mov    %esp,%ebp
80104703:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104706:	e8 49 f9 ff ff       	call   80104054 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010470b:	83 ec 0c             	sub    $0xc,%esp
8010470e:	68 60 ff 10 80       	push   $0x8010ff60
80104713:	e8 ae 04 00 00       	call   80104bc6 <acquire>
80104718:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010471b:	c7 45 f4 94 ff 10 80 	movl   $0x8010ff94,-0xc(%ebp)
80104722:	eb 63                	jmp    80104787 <scheduler+0x87>
      if(p->state != RUNNABLE)
80104724:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104727:	8b 40 0c             	mov    0xc(%eax),%eax
8010472a:	83 f8 03             	cmp    $0x3,%eax
8010472d:	75 53                	jne    80104782 <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
8010472f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104732:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104738:	83 ec 0c             	sub    $0xc,%esp
8010473b:	ff 75 f4             	pushl  -0xc(%ebp)
8010473e:	e8 03 33 00 00       	call   80107a46 <switchuvm>
80104743:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104746:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104749:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104750:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104756:	8b 40 1c             	mov    0x1c(%eax),%eax
80104759:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104760:	83 c2 04             	add    $0x4,%edx
80104763:	83 ec 08             	sub    $0x8,%esp
80104766:	50                   	push   %eax
80104767:	52                   	push   %edx
80104768:	e8 30 09 00 00       	call   8010509d <swtch>
8010476d:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104770:	e8 b4 32 00 00       	call   80107a29 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104775:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010477c:	00 00 00 00 
80104780:	eb 01                	jmp    80104783 <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104782:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104783:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104787:	81 7d f4 94 1e 11 80 	cmpl   $0x80111e94,-0xc(%ebp)
8010478e:	72 94                	jb     80104724 <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104790:	83 ec 0c             	sub    $0xc,%esp
80104793:	68 60 ff 10 80       	push   $0x8010ff60
80104798:	e8 90 04 00 00       	call   80104c2d <release>
8010479d:	83 c4 10             	add    $0x10,%esp

  }
801047a0:	e9 61 ff ff ff       	jmp    80104706 <scheduler+0x6>

801047a5 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
801047a5:	55                   	push   %ebp
801047a6:	89 e5                	mov    %esp,%ebp
801047a8:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
801047ab:	83 ec 0c             	sub    $0xc,%esp
801047ae:	68 60 ff 10 80       	push   $0x8010ff60
801047b3:	e8 41 05 00 00       	call   80104cf9 <holding>
801047b8:	83 c4 10             	add    $0x10,%esp
801047bb:	85 c0                	test   %eax,%eax
801047bd:	75 0d                	jne    801047cc <sched+0x27>
    panic("sched ptable.lock");
801047bf:	83 ec 0c             	sub    $0xc,%esp
801047c2:	68 8d 84 10 80       	push   $0x8010848d
801047c7:	e8 9a bd ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
801047cc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801047d2:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801047d8:	83 f8 01             	cmp    $0x1,%eax
801047db:	74 0d                	je     801047ea <sched+0x45>
    panic("sched locks");
801047dd:	83 ec 0c             	sub    $0xc,%esp
801047e0:	68 9f 84 10 80       	push   $0x8010849f
801047e5:	e8 7c bd ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
801047ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f0:	8b 40 0c             	mov    0xc(%eax),%eax
801047f3:	83 f8 04             	cmp    $0x4,%eax
801047f6:	75 0d                	jne    80104805 <sched+0x60>
    panic("sched running");
801047f8:	83 ec 0c             	sub    $0xc,%esp
801047fb:	68 ab 84 10 80       	push   $0x801084ab
80104800:	e8 61 bd ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104805:	e8 3a f8 ff ff       	call   80104044 <readeflags>
8010480a:	25 00 02 00 00       	and    $0x200,%eax
8010480f:	85 c0                	test   %eax,%eax
80104811:	74 0d                	je     80104820 <sched+0x7b>
    panic("sched interruptible");
80104813:	83 ec 0c             	sub    $0xc,%esp
80104816:	68 b9 84 10 80       	push   $0x801084b9
8010481b:	e8 46 bd ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80104820:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104826:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010482c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
8010482f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104835:	8b 40 04             	mov    0x4(%eax),%eax
80104838:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010483f:	83 c2 1c             	add    $0x1c,%edx
80104842:	83 ec 08             	sub    $0x8,%esp
80104845:	50                   	push   %eax
80104846:	52                   	push   %edx
80104847:	e8 51 08 00 00       	call   8010509d <swtch>
8010484c:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
8010484f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104855:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104858:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010485e:	90                   	nop
8010485f:	c9                   	leave  
80104860:	c3                   	ret    

80104861 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104861:	55                   	push   %ebp
80104862:	89 e5                	mov    %esp,%ebp
80104864:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104867:	83 ec 0c             	sub    $0xc,%esp
8010486a:	68 60 ff 10 80       	push   $0x8010ff60
8010486f:	e8 52 03 00 00       	call   80104bc6 <acquire>
80104874:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104877:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010487d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104884:	e8 1c ff ff ff       	call   801047a5 <sched>
  release(&ptable.lock);
80104889:	83 ec 0c             	sub    $0xc,%esp
8010488c:	68 60 ff 10 80       	push   $0x8010ff60
80104891:	e8 97 03 00 00       	call   80104c2d <release>
80104896:	83 c4 10             	add    $0x10,%esp
}
80104899:	90                   	nop
8010489a:	c9                   	leave  
8010489b:	c3                   	ret    

8010489c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010489c:	55                   	push   %ebp
8010489d:	89 e5                	mov    %esp,%ebp
8010489f:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801048a2:	83 ec 0c             	sub    $0xc,%esp
801048a5:	68 60 ff 10 80       	push   $0x8010ff60
801048aa:	e8 7e 03 00 00       	call   80104c2d <release>
801048af:	83 c4 10             	add    $0x10,%esp

  if (first) {
801048b2:	a1 08 b0 10 80       	mov    0x8010b008,%eax
801048b7:	85 c0                	test   %eax,%eax
801048b9:	74 0f                	je     801048ca <forkret+0x2e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
801048bb:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
801048c2:	00 00 00 
    initlog();
801048c5:	e8 8b e7 ff ff       	call   80103055 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
801048ca:	90                   	nop
801048cb:	c9                   	leave  
801048cc:	c3                   	ret    

801048cd <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801048cd:	55                   	push   %ebp
801048ce:	89 e5                	mov    %esp,%ebp
801048d0:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
801048d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d9:	85 c0                	test   %eax,%eax
801048db:	75 0d                	jne    801048ea <sleep+0x1d>
    panic("sleep");
801048dd:	83 ec 0c             	sub    $0xc,%esp
801048e0:	68 cd 84 10 80       	push   $0x801084cd
801048e5:	e8 7c bc ff ff       	call   80100566 <panic>

  if(lk == 0)
801048ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801048ee:	75 0d                	jne    801048fd <sleep+0x30>
    panic("sleep without lk");
801048f0:	83 ec 0c             	sub    $0xc,%esp
801048f3:	68 d3 84 10 80       	push   $0x801084d3
801048f8:	e8 69 bc ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801048fd:	81 7d 0c 60 ff 10 80 	cmpl   $0x8010ff60,0xc(%ebp)
80104904:	74 1e                	je     80104924 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104906:	83 ec 0c             	sub    $0xc,%esp
80104909:	68 60 ff 10 80       	push   $0x8010ff60
8010490e:	e8 b3 02 00 00       	call   80104bc6 <acquire>
80104913:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104916:	83 ec 0c             	sub    $0xc,%esp
80104919:	ff 75 0c             	pushl  0xc(%ebp)
8010491c:	e8 0c 03 00 00       	call   80104c2d <release>
80104921:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104924:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010492a:	8b 55 08             	mov    0x8(%ebp),%edx
8010492d:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104930:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104936:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
8010493d:	e8 63 fe ff ff       	call   801047a5 <sched>

  // Tidy up.
  proc->chan = 0;
80104942:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104948:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010494f:	81 7d 0c 60 ff 10 80 	cmpl   $0x8010ff60,0xc(%ebp)
80104956:	74 1e                	je     80104976 <sleep+0xa9>
    release(&ptable.lock);
80104958:	83 ec 0c             	sub    $0xc,%esp
8010495b:	68 60 ff 10 80       	push   $0x8010ff60
80104960:	e8 c8 02 00 00       	call   80104c2d <release>
80104965:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104968:	83 ec 0c             	sub    $0xc,%esp
8010496b:	ff 75 0c             	pushl  0xc(%ebp)
8010496e:	e8 53 02 00 00       	call   80104bc6 <acquire>
80104973:	83 c4 10             	add    $0x10,%esp
  }
}
80104976:	90                   	nop
80104977:	c9                   	leave  
80104978:	c3                   	ret    

80104979 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104979:	55                   	push   %ebp
8010497a:	89 e5                	mov    %esp,%ebp
8010497c:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010497f:	c7 45 fc 94 ff 10 80 	movl   $0x8010ff94,-0x4(%ebp)
80104986:	eb 24                	jmp    801049ac <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104988:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010498b:	8b 40 0c             	mov    0xc(%eax),%eax
8010498e:	83 f8 02             	cmp    $0x2,%eax
80104991:	75 15                	jne    801049a8 <wakeup1+0x2f>
80104993:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104996:	8b 40 20             	mov    0x20(%eax),%eax
80104999:	3b 45 08             	cmp    0x8(%ebp),%eax
8010499c:	75 0a                	jne    801049a8 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010499e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049a1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801049a8:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
801049ac:	81 7d fc 94 1e 11 80 	cmpl   $0x80111e94,-0x4(%ebp)
801049b3:	72 d3                	jb     80104988 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
801049b5:	90                   	nop
801049b6:	c9                   	leave  
801049b7:	c3                   	ret    

801049b8 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801049b8:	55                   	push   %ebp
801049b9:	89 e5                	mov    %esp,%ebp
801049bb:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801049be:	83 ec 0c             	sub    $0xc,%esp
801049c1:	68 60 ff 10 80       	push   $0x8010ff60
801049c6:	e8 fb 01 00 00       	call   80104bc6 <acquire>
801049cb:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801049ce:	83 ec 0c             	sub    $0xc,%esp
801049d1:	ff 75 08             	pushl  0x8(%ebp)
801049d4:	e8 a0 ff ff ff       	call   80104979 <wakeup1>
801049d9:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801049dc:	83 ec 0c             	sub    $0xc,%esp
801049df:	68 60 ff 10 80       	push   $0x8010ff60
801049e4:	e8 44 02 00 00       	call   80104c2d <release>
801049e9:	83 c4 10             	add    $0x10,%esp
}
801049ec:	90                   	nop
801049ed:	c9                   	leave  
801049ee:	c3                   	ret    

801049ef <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801049ef:	55                   	push   %ebp
801049f0:	89 e5                	mov    %esp,%ebp
801049f2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801049f5:	83 ec 0c             	sub    $0xc,%esp
801049f8:	68 60 ff 10 80       	push   $0x8010ff60
801049fd:	e8 c4 01 00 00       	call   80104bc6 <acquire>
80104a02:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a05:	c7 45 f4 94 ff 10 80 	movl   $0x8010ff94,-0xc(%ebp)
80104a0c:	eb 45                	jmp    80104a53 <kill+0x64>
    if(p->pid == pid){
80104a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a11:	8b 40 10             	mov    0x10(%eax),%eax
80104a14:	3b 45 08             	cmp    0x8(%ebp),%eax
80104a17:	75 36                	jne    80104a4f <kill+0x60>
      p->killed = 1;
80104a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a1c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a26:	8b 40 0c             	mov    0xc(%eax),%eax
80104a29:	83 f8 02             	cmp    $0x2,%eax
80104a2c:	75 0a                	jne    80104a38 <kill+0x49>
        p->state = RUNNABLE;
80104a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a31:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104a38:	83 ec 0c             	sub    $0xc,%esp
80104a3b:	68 60 ff 10 80       	push   $0x8010ff60
80104a40:	e8 e8 01 00 00       	call   80104c2d <release>
80104a45:	83 c4 10             	add    $0x10,%esp
      return 0;
80104a48:	b8 00 00 00 00       	mov    $0x0,%eax
80104a4d:	eb 22                	jmp    80104a71 <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a4f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a53:	81 7d f4 94 1e 11 80 	cmpl   $0x80111e94,-0xc(%ebp)
80104a5a:	72 b2                	jb     80104a0e <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104a5c:	83 ec 0c             	sub    $0xc,%esp
80104a5f:	68 60 ff 10 80       	push   $0x8010ff60
80104a64:	e8 c4 01 00 00       	call   80104c2d <release>
80104a69:	83 c4 10             	add    $0x10,%esp
  return -1;
80104a6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104a71:	c9                   	leave  
80104a72:	c3                   	ret    

80104a73 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104a73:	55                   	push   %ebp
80104a74:	89 e5                	mov    %esp,%ebp
80104a76:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a79:	c7 45 f0 94 ff 10 80 	movl   $0x8010ff94,-0x10(%ebp)
80104a80:	e9 d7 00 00 00       	jmp    80104b5c <procdump+0xe9>
    if(p->state == UNUSED)
80104a85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a88:	8b 40 0c             	mov    0xc(%eax),%eax
80104a8b:	85 c0                	test   %eax,%eax
80104a8d:	0f 84 c4 00 00 00    	je     80104b57 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a96:	8b 40 0c             	mov    0xc(%eax),%eax
80104a99:	83 f8 05             	cmp    $0x5,%eax
80104a9c:	77 23                	ja     80104ac1 <procdump+0x4e>
80104a9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104aa1:	8b 40 0c             	mov    0xc(%eax),%eax
80104aa4:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104aab:	85 c0                	test   %eax,%eax
80104aad:	74 12                	je     80104ac1 <procdump+0x4e>
      state = states[p->state];
80104aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ab2:	8b 40 0c             	mov    0xc(%eax),%eax
80104ab5:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104abc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104abf:	eb 07                	jmp    80104ac8 <procdump+0x55>
    else
      state = "???";
80104ac1:	c7 45 ec e4 84 10 80 	movl   $0x801084e4,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104acb:	8d 50 6c             	lea    0x6c(%eax),%edx
80104ace:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ad1:	8b 40 10             	mov    0x10(%eax),%eax
80104ad4:	52                   	push   %edx
80104ad5:	ff 75 ec             	pushl  -0x14(%ebp)
80104ad8:	50                   	push   %eax
80104ad9:	68 e8 84 10 80       	push   $0x801084e8
80104ade:	e8 e3 b8 ff ff       	call   801003c6 <cprintf>
80104ae3:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104ae6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ae9:	8b 40 0c             	mov    0xc(%eax),%eax
80104aec:	83 f8 02             	cmp    $0x2,%eax
80104aef:	75 54                	jne    80104b45 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104af1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104af4:	8b 40 1c             	mov    0x1c(%eax),%eax
80104af7:	8b 40 0c             	mov    0xc(%eax),%eax
80104afa:	83 c0 08             	add    $0x8,%eax
80104afd:	89 c2                	mov    %eax,%edx
80104aff:	83 ec 08             	sub    $0x8,%esp
80104b02:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104b05:	50                   	push   %eax
80104b06:	52                   	push   %edx
80104b07:	e8 73 01 00 00       	call   80104c7f <getcallerpcs>
80104b0c:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104b0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104b16:	eb 1c                	jmp    80104b34 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104b1f:	83 ec 08             	sub    $0x8,%esp
80104b22:	50                   	push   %eax
80104b23:	68 f1 84 10 80       	push   $0x801084f1
80104b28:	e8 99 b8 ff ff       	call   801003c6 <cprintf>
80104b2d:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104b30:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104b34:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104b38:	7f 0b                	jg     80104b45 <procdump+0xd2>
80104b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b3d:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104b41:	85 c0                	test   %eax,%eax
80104b43:	75 d3                	jne    80104b18 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104b45:	83 ec 0c             	sub    $0xc,%esp
80104b48:	68 f5 84 10 80       	push   $0x801084f5
80104b4d:	e8 74 b8 ff ff       	call   801003c6 <cprintf>
80104b52:	83 c4 10             	add    $0x10,%esp
80104b55:	eb 01                	jmp    80104b58 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104b57:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b58:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104b5c:	81 7d f0 94 1e 11 80 	cmpl   $0x80111e94,-0x10(%ebp)
80104b63:	0f 82 1c ff ff ff    	jb     80104a85 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104b69:	90                   	nop
80104b6a:	c9                   	leave  
80104b6b:	c3                   	ret    

80104b6c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104b6c:	55                   	push   %ebp
80104b6d:	89 e5                	mov    %esp,%ebp
80104b6f:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b72:	9c                   	pushf  
80104b73:	58                   	pop    %eax
80104b74:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b77:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b7a:	c9                   	leave  
80104b7b:	c3                   	ret    

80104b7c <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104b7c:	55                   	push   %ebp
80104b7d:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104b7f:	fa                   	cli    
}
80104b80:	90                   	nop
80104b81:	5d                   	pop    %ebp
80104b82:	c3                   	ret    

80104b83 <sti>:

static inline void
sti(void)
{
80104b83:	55                   	push   %ebp
80104b84:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104b86:	fb                   	sti    
}
80104b87:	90                   	nop
80104b88:	5d                   	pop    %ebp
80104b89:	c3                   	ret    

80104b8a <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104b8a:	55                   	push   %ebp
80104b8b:	89 e5                	mov    %esp,%ebp
80104b8d:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104b90:	8b 55 08             	mov    0x8(%ebp),%edx
80104b93:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b96:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b99:	f0 87 02             	lock xchg %eax,(%edx)
80104b9c:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104b9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ba2:	c9                   	leave  
80104ba3:	c3                   	ret    

80104ba4 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104ba4:	55                   	push   %ebp
80104ba5:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80104baa:	8b 55 0c             	mov    0xc(%ebp),%edx
80104bad:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bbc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104bc3:	90                   	nop
80104bc4:	5d                   	pop    %ebp
80104bc5:	c3                   	ret    

80104bc6 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104bc6:	55                   	push   %ebp
80104bc7:	89 e5                	mov    %esp,%ebp
80104bc9:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104bcc:	e8 52 01 00 00       	call   80104d23 <pushcli>
  if(holding(lk))
80104bd1:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd4:	83 ec 0c             	sub    $0xc,%esp
80104bd7:	50                   	push   %eax
80104bd8:	e8 1c 01 00 00       	call   80104cf9 <holding>
80104bdd:	83 c4 10             	add    $0x10,%esp
80104be0:	85 c0                	test   %eax,%eax
80104be2:	74 0d                	je     80104bf1 <acquire+0x2b>
    panic("acquire");
80104be4:	83 ec 0c             	sub    $0xc,%esp
80104be7:	68 21 85 10 80       	push   $0x80108521
80104bec:	e8 75 b9 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104bf1:	90                   	nop
80104bf2:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf5:	83 ec 08             	sub    $0x8,%esp
80104bf8:	6a 01                	push   $0x1
80104bfa:	50                   	push   %eax
80104bfb:	e8 8a ff ff ff       	call   80104b8a <xchg>
80104c00:	83 c4 10             	add    $0x10,%esp
80104c03:	85 c0                	test   %eax,%eax
80104c05:	75 eb                	jne    80104bf2 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104c07:	8b 45 08             	mov    0x8(%ebp),%eax
80104c0a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104c11:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104c14:	8b 45 08             	mov    0x8(%ebp),%eax
80104c17:	83 c0 0c             	add    $0xc,%eax
80104c1a:	83 ec 08             	sub    $0x8,%esp
80104c1d:	50                   	push   %eax
80104c1e:	8d 45 08             	lea    0x8(%ebp),%eax
80104c21:	50                   	push   %eax
80104c22:	e8 58 00 00 00       	call   80104c7f <getcallerpcs>
80104c27:	83 c4 10             	add    $0x10,%esp
}
80104c2a:	90                   	nop
80104c2b:	c9                   	leave  
80104c2c:	c3                   	ret    

80104c2d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104c2d:	55                   	push   %ebp
80104c2e:	89 e5                	mov    %esp,%ebp
80104c30:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104c33:	83 ec 0c             	sub    $0xc,%esp
80104c36:	ff 75 08             	pushl  0x8(%ebp)
80104c39:	e8 bb 00 00 00       	call   80104cf9 <holding>
80104c3e:	83 c4 10             	add    $0x10,%esp
80104c41:	85 c0                	test   %eax,%eax
80104c43:	75 0d                	jne    80104c52 <release+0x25>
    panic("release");
80104c45:	83 ec 0c             	sub    $0xc,%esp
80104c48:	68 29 85 10 80       	push   $0x80108529
80104c4d:	e8 14 b9 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80104c52:	8b 45 08             	mov    0x8(%ebp),%eax
80104c55:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80104c5f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104c66:	8b 45 08             	mov    0x8(%ebp),%eax
80104c69:	83 ec 08             	sub    $0x8,%esp
80104c6c:	6a 00                	push   $0x0
80104c6e:	50                   	push   %eax
80104c6f:	e8 16 ff ff ff       	call   80104b8a <xchg>
80104c74:	83 c4 10             	add    $0x10,%esp

  popcli();
80104c77:	e8 ec 00 00 00       	call   80104d68 <popcli>
}
80104c7c:	90                   	nop
80104c7d:	c9                   	leave  
80104c7e:	c3                   	ret    

80104c7f <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104c7f:	55                   	push   %ebp
80104c80:	89 e5                	mov    %esp,%ebp
80104c82:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104c85:	8b 45 08             	mov    0x8(%ebp),%eax
80104c88:	83 e8 08             	sub    $0x8,%eax
80104c8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104c8e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104c95:	eb 38                	jmp    80104ccf <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104c97:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104c9b:	74 53                	je     80104cf0 <getcallerpcs+0x71>
80104c9d:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104ca4:	76 4a                	jbe    80104cf0 <getcallerpcs+0x71>
80104ca6:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104caa:	74 44                	je     80104cf0 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104cac:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104caf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cb9:	01 c2                	add    %eax,%edx
80104cbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cbe:	8b 40 04             	mov    0x4(%eax),%eax
80104cc1:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104cc3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cc6:	8b 00                	mov    (%eax),%eax
80104cc8:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104ccb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104ccf:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104cd3:	7e c2                	jle    80104c97 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104cd5:	eb 19                	jmp    80104cf0 <getcallerpcs+0x71>
    pcs[i] = 0;
80104cd7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104cda:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ce4:	01 d0                	add    %edx,%eax
80104ce6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104cec:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104cf0:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104cf4:	7e e1                	jle    80104cd7 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80104cf6:	90                   	nop
80104cf7:	c9                   	leave  
80104cf8:	c3                   	ret    

80104cf9 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104cf9:	55                   	push   %ebp
80104cfa:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104cfc:	8b 45 08             	mov    0x8(%ebp),%eax
80104cff:	8b 00                	mov    (%eax),%eax
80104d01:	85 c0                	test   %eax,%eax
80104d03:	74 17                	je     80104d1c <holding+0x23>
80104d05:	8b 45 08             	mov    0x8(%ebp),%eax
80104d08:	8b 50 08             	mov    0x8(%eax),%edx
80104d0b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d11:	39 c2                	cmp    %eax,%edx
80104d13:	75 07                	jne    80104d1c <holding+0x23>
80104d15:	b8 01 00 00 00       	mov    $0x1,%eax
80104d1a:	eb 05                	jmp    80104d21 <holding+0x28>
80104d1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d21:	5d                   	pop    %ebp
80104d22:	c3                   	ret    

80104d23 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104d23:	55                   	push   %ebp
80104d24:	89 e5                	mov    %esp,%ebp
80104d26:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80104d29:	e8 3e fe ff ff       	call   80104b6c <readeflags>
80104d2e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80104d31:	e8 46 fe ff ff       	call   80104b7c <cli>
  if(cpu->ncli++ == 0)
80104d36:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104d3d:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80104d43:	8d 48 01             	lea    0x1(%eax),%ecx
80104d46:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80104d4c:	85 c0                	test   %eax,%eax
80104d4e:	75 15                	jne    80104d65 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80104d50:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d56:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104d59:	81 e2 00 02 00 00    	and    $0x200,%edx
80104d5f:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104d65:	90                   	nop
80104d66:	c9                   	leave  
80104d67:	c3                   	ret    

80104d68 <popcli>:

void
popcli(void)
{
80104d68:	55                   	push   %ebp
80104d69:	89 e5                	mov    %esp,%ebp
80104d6b:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104d6e:	e8 f9 fd ff ff       	call   80104b6c <readeflags>
80104d73:	25 00 02 00 00       	and    $0x200,%eax
80104d78:	85 c0                	test   %eax,%eax
80104d7a:	74 0d                	je     80104d89 <popcli+0x21>
    panic("popcli - interruptible");
80104d7c:	83 ec 0c             	sub    $0xc,%esp
80104d7f:	68 31 85 10 80       	push   $0x80108531
80104d84:	e8 dd b7 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80104d89:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d8f:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104d95:	83 ea 01             	sub    $0x1,%edx
80104d98:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104d9e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104da4:	85 c0                	test   %eax,%eax
80104da6:	79 0d                	jns    80104db5 <popcli+0x4d>
    panic("popcli");
80104da8:	83 ec 0c             	sub    $0xc,%esp
80104dab:	68 48 85 10 80       	push   $0x80108548
80104db0:	e8 b1 b7 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80104db5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104dbb:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104dc1:	85 c0                	test   %eax,%eax
80104dc3:	75 15                	jne    80104dda <popcli+0x72>
80104dc5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104dcb:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104dd1:	85 c0                	test   %eax,%eax
80104dd3:	74 05                	je     80104dda <popcli+0x72>
    sti();
80104dd5:	e8 a9 fd ff ff       	call   80104b83 <sti>
}
80104dda:	90                   	nop
80104ddb:	c9                   	leave  
80104ddc:	c3                   	ret    

80104ddd <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80104ddd:	55                   	push   %ebp
80104dde:	89 e5                	mov    %esp,%ebp
80104de0:	57                   	push   %edi
80104de1:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104de2:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104de5:	8b 55 10             	mov    0x10(%ebp),%edx
80104de8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104deb:	89 cb                	mov    %ecx,%ebx
80104ded:	89 df                	mov    %ebx,%edi
80104def:	89 d1                	mov    %edx,%ecx
80104df1:	fc                   	cld    
80104df2:	f3 aa                	rep stos %al,%es:(%edi)
80104df4:	89 ca                	mov    %ecx,%edx
80104df6:	89 fb                	mov    %edi,%ebx
80104df8:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104dfb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104dfe:	90                   	nop
80104dff:	5b                   	pop    %ebx
80104e00:	5f                   	pop    %edi
80104e01:	5d                   	pop    %ebp
80104e02:	c3                   	ret    

80104e03 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80104e03:	55                   	push   %ebp
80104e04:	89 e5                	mov    %esp,%ebp
80104e06:	57                   	push   %edi
80104e07:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104e08:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e0b:	8b 55 10             	mov    0x10(%ebp),%edx
80104e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e11:	89 cb                	mov    %ecx,%ebx
80104e13:	89 df                	mov    %ebx,%edi
80104e15:	89 d1                	mov    %edx,%ecx
80104e17:	fc                   	cld    
80104e18:	f3 ab                	rep stos %eax,%es:(%edi)
80104e1a:	89 ca                	mov    %ecx,%edx
80104e1c:	89 fb                	mov    %edi,%ebx
80104e1e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104e21:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104e24:	90                   	nop
80104e25:	5b                   	pop    %ebx
80104e26:	5f                   	pop    %edi
80104e27:	5d                   	pop    %ebp
80104e28:	c3                   	ret    

80104e29 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104e29:	55                   	push   %ebp
80104e2a:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e2f:	83 e0 03             	and    $0x3,%eax
80104e32:	85 c0                	test   %eax,%eax
80104e34:	75 43                	jne    80104e79 <memset+0x50>
80104e36:	8b 45 10             	mov    0x10(%ebp),%eax
80104e39:	83 e0 03             	and    $0x3,%eax
80104e3c:	85 c0                	test   %eax,%eax
80104e3e:	75 39                	jne    80104e79 <memset+0x50>
    c &= 0xFF;
80104e40:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104e47:	8b 45 10             	mov    0x10(%ebp),%eax
80104e4a:	c1 e8 02             	shr    $0x2,%eax
80104e4d:	89 c1                	mov    %eax,%ecx
80104e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e52:	c1 e0 18             	shl    $0x18,%eax
80104e55:	89 c2                	mov    %eax,%edx
80104e57:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e5a:	c1 e0 10             	shl    $0x10,%eax
80104e5d:	09 c2                	or     %eax,%edx
80104e5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e62:	c1 e0 08             	shl    $0x8,%eax
80104e65:	09 d0                	or     %edx,%eax
80104e67:	0b 45 0c             	or     0xc(%ebp),%eax
80104e6a:	51                   	push   %ecx
80104e6b:	50                   	push   %eax
80104e6c:	ff 75 08             	pushl  0x8(%ebp)
80104e6f:	e8 8f ff ff ff       	call   80104e03 <stosl>
80104e74:	83 c4 0c             	add    $0xc,%esp
80104e77:	eb 12                	jmp    80104e8b <memset+0x62>
  } else
    stosb(dst, c, n);
80104e79:	8b 45 10             	mov    0x10(%ebp),%eax
80104e7c:	50                   	push   %eax
80104e7d:	ff 75 0c             	pushl  0xc(%ebp)
80104e80:	ff 75 08             	pushl  0x8(%ebp)
80104e83:	e8 55 ff ff ff       	call   80104ddd <stosb>
80104e88:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104e8b:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e8e:	c9                   	leave  
80104e8f:	c3                   	ret    

80104e90 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104e90:	55                   	push   %ebp
80104e91:	89 e5                	mov    %esp,%ebp
80104e93:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80104e96:	8b 45 08             	mov    0x8(%ebp),%eax
80104e99:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e9f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104ea2:	eb 30                	jmp    80104ed4 <memcmp+0x44>
    if(*s1 != *s2)
80104ea4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ea7:	0f b6 10             	movzbl (%eax),%edx
80104eaa:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ead:	0f b6 00             	movzbl (%eax),%eax
80104eb0:	38 c2                	cmp    %al,%dl
80104eb2:	74 18                	je     80104ecc <memcmp+0x3c>
      return *s1 - *s2;
80104eb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eb7:	0f b6 00             	movzbl (%eax),%eax
80104eba:	0f b6 d0             	movzbl %al,%edx
80104ebd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ec0:	0f b6 00             	movzbl (%eax),%eax
80104ec3:	0f b6 c0             	movzbl %al,%eax
80104ec6:	29 c2                	sub    %eax,%edx
80104ec8:	89 d0                	mov    %edx,%eax
80104eca:	eb 1a                	jmp    80104ee6 <memcmp+0x56>
    s1++, s2++;
80104ecc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104ed0:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104ed4:	8b 45 10             	mov    0x10(%ebp),%eax
80104ed7:	8d 50 ff             	lea    -0x1(%eax),%edx
80104eda:	89 55 10             	mov    %edx,0x10(%ebp)
80104edd:	85 c0                	test   %eax,%eax
80104edf:	75 c3                	jne    80104ea4 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80104ee1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ee6:	c9                   	leave  
80104ee7:	c3                   	ret    

80104ee8 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104ee8:	55                   	push   %ebp
80104ee9:	89 e5                	mov    %esp,%ebp
80104eeb:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104eee:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ef1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104ef4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104efa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104efd:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104f00:	73 54                	jae    80104f56 <memmove+0x6e>
80104f02:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f05:	8b 45 10             	mov    0x10(%ebp),%eax
80104f08:	01 d0                	add    %edx,%eax
80104f0a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104f0d:	76 47                	jbe    80104f56 <memmove+0x6e>
    s += n;
80104f0f:	8b 45 10             	mov    0x10(%ebp),%eax
80104f12:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104f15:	8b 45 10             	mov    0x10(%ebp),%eax
80104f18:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104f1b:	eb 13                	jmp    80104f30 <memmove+0x48>
      *--d = *--s;
80104f1d:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104f21:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104f25:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f28:	0f b6 10             	movzbl (%eax),%edx
80104f2b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f2e:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80104f30:	8b 45 10             	mov    0x10(%ebp),%eax
80104f33:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f36:	89 55 10             	mov    %edx,0x10(%ebp)
80104f39:	85 c0                	test   %eax,%eax
80104f3b:	75 e0                	jne    80104f1d <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104f3d:	eb 24                	jmp    80104f63 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80104f3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f42:	8d 50 01             	lea    0x1(%eax),%edx
80104f45:	89 55 f8             	mov    %edx,-0x8(%ebp)
80104f48:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f4b:	8d 4a 01             	lea    0x1(%edx),%ecx
80104f4e:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80104f51:	0f b6 12             	movzbl (%edx),%edx
80104f54:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80104f56:	8b 45 10             	mov    0x10(%ebp),%eax
80104f59:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f5c:	89 55 10             	mov    %edx,0x10(%ebp)
80104f5f:	85 c0                	test   %eax,%eax
80104f61:	75 dc                	jne    80104f3f <memmove+0x57>
      *d++ = *s++;

  return dst;
80104f63:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104f66:	c9                   	leave  
80104f67:	c3                   	ret    

80104f68 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104f68:	55                   	push   %ebp
80104f69:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104f6b:	ff 75 10             	pushl  0x10(%ebp)
80104f6e:	ff 75 0c             	pushl  0xc(%ebp)
80104f71:	ff 75 08             	pushl  0x8(%ebp)
80104f74:	e8 6f ff ff ff       	call   80104ee8 <memmove>
80104f79:	83 c4 0c             	add    $0xc,%esp
}
80104f7c:	c9                   	leave  
80104f7d:	c3                   	ret    

80104f7e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104f7e:	55                   	push   %ebp
80104f7f:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104f81:	eb 0c                	jmp    80104f8f <strncmp+0x11>
    n--, p++, q++;
80104f83:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f87:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104f8b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80104f8f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f93:	74 1a                	je     80104faf <strncmp+0x31>
80104f95:	8b 45 08             	mov    0x8(%ebp),%eax
80104f98:	0f b6 00             	movzbl (%eax),%eax
80104f9b:	84 c0                	test   %al,%al
80104f9d:	74 10                	je     80104faf <strncmp+0x31>
80104f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa2:	0f b6 10             	movzbl (%eax),%edx
80104fa5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fa8:	0f b6 00             	movzbl (%eax),%eax
80104fab:	38 c2                	cmp    %al,%dl
80104fad:	74 d4                	je     80104f83 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80104faf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fb3:	75 07                	jne    80104fbc <strncmp+0x3e>
    return 0;
80104fb5:	b8 00 00 00 00       	mov    $0x0,%eax
80104fba:	eb 16                	jmp    80104fd2 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80104fbf:	0f b6 00             	movzbl (%eax),%eax
80104fc2:	0f b6 d0             	movzbl %al,%edx
80104fc5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fc8:	0f b6 00             	movzbl (%eax),%eax
80104fcb:	0f b6 c0             	movzbl %al,%eax
80104fce:	29 c2                	sub    %eax,%edx
80104fd0:	89 d0                	mov    %edx,%eax
}
80104fd2:	5d                   	pop    %ebp
80104fd3:	c3                   	ret    

80104fd4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104fd4:	55                   	push   %ebp
80104fd5:	89 e5                	mov    %esp,%ebp
80104fd7:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80104fda:	8b 45 08             	mov    0x8(%ebp),%eax
80104fdd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104fe0:	90                   	nop
80104fe1:	8b 45 10             	mov    0x10(%ebp),%eax
80104fe4:	8d 50 ff             	lea    -0x1(%eax),%edx
80104fe7:	89 55 10             	mov    %edx,0x10(%ebp)
80104fea:	85 c0                	test   %eax,%eax
80104fec:	7e 2c                	jle    8010501a <strncpy+0x46>
80104fee:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff1:	8d 50 01             	lea    0x1(%eax),%edx
80104ff4:	89 55 08             	mov    %edx,0x8(%ebp)
80104ff7:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ffa:	8d 4a 01             	lea    0x1(%edx),%ecx
80104ffd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105000:	0f b6 12             	movzbl (%edx),%edx
80105003:	88 10                	mov    %dl,(%eax)
80105005:	0f b6 00             	movzbl (%eax),%eax
80105008:	84 c0                	test   %al,%al
8010500a:	75 d5                	jne    80104fe1 <strncpy+0xd>
    ;
  while(n-- > 0)
8010500c:	eb 0c                	jmp    8010501a <strncpy+0x46>
    *s++ = 0;
8010500e:	8b 45 08             	mov    0x8(%ebp),%eax
80105011:	8d 50 01             	lea    0x1(%eax),%edx
80105014:	89 55 08             	mov    %edx,0x8(%ebp)
80105017:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010501a:	8b 45 10             	mov    0x10(%ebp),%eax
8010501d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105020:	89 55 10             	mov    %edx,0x10(%ebp)
80105023:	85 c0                	test   %eax,%eax
80105025:	7f e7                	jg     8010500e <strncpy+0x3a>
    *s++ = 0;
  return os;
80105027:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010502a:	c9                   	leave  
8010502b:	c3                   	ret    

8010502c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010502c:	55                   	push   %ebp
8010502d:	89 e5                	mov    %esp,%ebp
8010502f:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105032:	8b 45 08             	mov    0x8(%ebp),%eax
80105035:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105038:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010503c:	7f 05                	jg     80105043 <safestrcpy+0x17>
    return os;
8010503e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105041:	eb 31                	jmp    80105074 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105043:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105047:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010504b:	7e 1e                	jle    8010506b <safestrcpy+0x3f>
8010504d:	8b 45 08             	mov    0x8(%ebp),%eax
80105050:	8d 50 01             	lea    0x1(%eax),%edx
80105053:	89 55 08             	mov    %edx,0x8(%ebp)
80105056:	8b 55 0c             	mov    0xc(%ebp),%edx
80105059:	8d 4a 01             	lea    0x1(%edx),%ecx
8010505c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010505f:	0f b6 12             	movzbl (%edx),%edx
80105062:	88 10                	mov    %dl,(%eax)
80105064:	0f b6 00             	movzbl (%eax),%eax
80105067:	84 c0                	test   %al,%al
80105069:	75 d8                	jne    80105043 <safestrcpy+0x17>
    ;
  *s = 0;
8010506b:	8b 45 08             	mov    0x8(%ebp),%eax
8010506e:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105071:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105074:	c9                   	leave  
80105075:	c3                   	ret    

80105076 <strlen>:

int
strlen(const char *s)
{
80105076:	55                   	push   %ebp
80105077:	89 e5                	mov    %esp,%ebp
80105079:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010507c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105083:	eb 04                	jmp    80105089 <strlen+0x13>
80105085:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105089:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010508c:	8b 45 08             	mov    0x8(%ebp),%eax
8010508f:	01 d0                	add    %edx,%eax
80105091:	0f b6 00             	movzbl (%eax),%eax
80105094:	84 c0                	test   %al,%al
80105096:	75 ed                	jne    80105085 <strlen+0xf>
    ;
  return n;
80105098:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010509b:	c9                   	leave  
8010509c:	c3                   	ret    

8010509d <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010509d:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801050a1:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801050a5:	55                   	push   %ebp
  pushl %ebx
801050a6:	53                   	push   %ebx
  pushl %esi
801050a7:	56                   	push   %esi
  pushl %edi
801050a8:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801050a9:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801050ab:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801050ad:	5f                   	pop    %edi
  popl %esi
801050ae:	5e                   	pop    %esi
  popl %ebx
801050af:	5b                   	pop    %ebx
  popl %ebp
801050b0:	5d                   	pop    %ebp
  ret
801050b1:	c3                   	ret    

801050b2 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801050b2:	55                   	push   %ebp
801050b3:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801050b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050bb:	8b 00                	mov    (%eax),%eax
801050bd:	3b 45 08             	cmp    0x8(%ebp),%eax
801050c0:	76 12                	jbe    801050d4 <fetchint+0x22>
801050c2:	8b 45 08             	mov    0x8(%ebp),%eax
801050c5:	8d 50 04             	lea    0x4(%eax),%edx
801050c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050ce:	8b 00                	mov    (%eax),%eax
801050d0:	39 c2                	cmp    %eax,%edx
801050d2:	76 07                	jbe    801050db <fetchint+0x29>
    return -1;
801050d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050d9:	eb 0f                	jmp    801050ea <fetchint+0x38>
  *ip = *(int*)(addr);
801050db:	8b 45 08             	mov    0x8(%ebp),%eax
801050de:	8b 10                	mov    (%eax),%edx
801050e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801050e3:	89 10                	mov    %edx,(%eax)
  return 0;
801050e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050ea:	5d                   	pop    %ebp
801050eb:	c3                   	ret    

801050ec <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801050ec:	55                   	push   %ebp
801050ed:	89 e5                	mov    %esp,%ebp
801050ef:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801050f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050f8:	8b 00                	mov    (%eax),%eax
801050fa:	3b 45 08             	cmp    0x8(%ebp),%eax
801050fd:	77 07                	ja     80105106 <fetchstr+0x1a>
    return -1;
801050ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105104:	eb 46                	jmp    8010514c <fetchstr+0x60>
  *pp = (char*)addr;
80105106:	8b 55 08             	mov    0x8(%ebp),%edx
80105109:	8b 45 0c             	mov    0xc(%ebp),%eax
8010510c:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
8010510e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105114:	8b 00                	mov    (%eax),%eax
80105116:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105119:	8b 45 0c             	mov    0xc(%ebp),%eax
8010511c:	8b 00                	mov    (%eax),%eax
8010511e:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105121:	eb 1c                	jmp    8010513f <fetchstr+0x53>
    if(*s == 0)
80105123:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105126:	0f b6 00             	movzbl (%eax),%eax
80105129:	84 c0                	test   %al,%al
8010512b:	75 0e                	jne    8010513b <fetchstr+0x4f>
      return s - *pp;
8010512d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105130:	8b 45 0c             	mov    0xc(%ebp),%eax
80105133:	8b 00                	mov    (%eax),%eax
80105135:	29 c2                	sub    %eax,%edx
80105137:	89 d0                	mov    %edx,%eax
80105139:	eb 11                	jmp    8010514c <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010513b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010513f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105142:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105145:	72 dc                	jb     80105123 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105147:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010514c:	c9                   	leave  
8010514d:	c3                   	ret    

8010514e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010514e:	55                   	push   %ebp
8010514f:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105151:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105157:	8b 40 18             	mov    0x18(%eax),%eax
8010515a:	8b 40 44             	mov    0x44(%eax),%eax
8010515d:	8b 55 08             	mov    0x8(%ebp),%edx
80105160:	c1 e2 02             	shl    $0x2,%edx
80105163:	01 d0                	add    %edx,%eax
80105165:	83 c0 04             	add    $0x4,%eax
80105168:	ff 75 0c             	pushl  0xc(%ebp)
8010516b:	50                   	push   %eax
8010516c:	e8 41 ff ff ff       	call   801050b2 <fetchint>
80105171:	83 c4 08             	add    $0x8,%esp
}
80105174:	c9                   	leave  
80105175:	c3                   	ret    

80105176 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105176:	55                   	push   %ebp
80105177:	89 e5                	mov    %esp,%ebp
80105179:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010517c:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010517f:	50                   	push   %eax
80105180:	ff 75 08             	pushl  0x8(%ebp)
80105183:	e8 c6 ff ff ff       	call   8010514e <argint>
80105188:	83 c4 08             	add    $0x8,%esp
8010518b:	85 c0                	test   %eax,%eax
8010518d:	79 07                	jns    80105196 <argptr+0x20>
    return -1;
8010518f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105194:	eb 3b                	jmp    801051d1 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105196:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010519c:	8b 00                	mov    (%eax),%eax
8010519e:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051a1:	39 d0                	cmp    %edx,%eax
801051a3:	76 16                	jbe    801051bb <argptr+0x45>
801051a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051a8:	89 c2                	mov    %eax,%edx
801051aa:	8b 45 10             	mov    0x10(%ebp),%eax
801051ad:	01 c2                	add    %eax,%edx
801051af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051b5:	8b 00                	mov    (%eax),%eax
801051b7:	39 c2                	cmp    %eax,%edx
801051b9:	76 07                	jbe    801051c2 <argptr+0x4c>
    return -1;
801051bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051c0:	eb 0f                	jmp    801051d1 <argptr+0x5b>
  *pp = (char*)i;
801051c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051c5:	89 c2                	mov    %eax,%edx
801051c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ca:	89 10                	mov    %edx,(%eax)
  return 0;
801051cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051d1:	c9                   	leave  
801051d2:	c3                   	ret    

801051d3 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801051d3:	55                   	push   %ebp
801051d4:	89 e5                	mov    %esp,%ebp
801051d6:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801051d9:	8d 45 fc             	lea    -0x4(%ebp),%eax
801051dc:	50                   	push   %eax
801051dd:	ff 75 08             	pushl  0x8(%ebp)
801051e0:	e8 69 ff ff ff       	call   8010514e <argint>
801051e5:	83 c4 08             	add    $0x8,%esp
801051e8:	85 c0                	test   %eax,%eax
801051ea:	79 07                	jns    801051f3 <argstr+0x20>
    return -1;
801051ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051f1:	eb 0f                	jmp    80105202 <argstr+0x2f>
  return fetchstr(addr, pp);
801051f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051f6:	ff 75 0c             	pushl  0xc(%ebp)
801051f9:	50                   	push   %eax
801051fa:	e8 ed fe ff ff       	call   801050ec <fetchstr>
801051ff:	83 c4 08             	add    $0x8,%esp
}
80105202:	c9                   	leave  
80105203:	c3                   	ret    

80105204 <syscall>:
[SYS_modifyCurrentProcessName] sys_modifyCurrentProcessName,
};

void
syscall(void)
{
80105204:	55                   	push   %ebp
80105205:	89 e5                	mov    %esp,%ebp
80105207:	53                   	push   %ebx
80105208:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
8010520b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105211:	8b 40 18             	mov    0x18(%eax),%eax
80105214:	8b 40 1c             	mov    0x1c(%eax),%eax
80105217:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010521a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010521e:	7e 30                	jle    80105250 <syscall+0x4c>
80105220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105223:	83 f8 19             	cmp    $0x19,%eax
80105226:	77 28                	ja     80105250 <syscall+0x4c>
80105228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010522b:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105232:	85 c0                	test   %eax,%eax
80105234:	74 1a                	je     80105250 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105236:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010523c:	8b 58 18             	mov    0x18(%eax),%ebx
8010523f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105242:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105249:	ff d0                	call   *%eax
8010524b:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010524e:	eb 34                	jmp    80105284 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105250:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105256:	8d 50 6c             	lea    0x6c(%eax),%edx
80105259:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010525f:	8b 40 10             	mov    0x10(%eax),%eax
80105262:	ff 75 f4             	pushl  -0xc(%ebp)
80105265:	52                   	push   %edx
80105266:	50                   	push   %eax
80105267:	68 4f 85 10 80       	push   $0x8010854f
8010526c:	e8 55 b1 ff ff       	call   801003c6 <cprintf>
80105271:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105274:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010527a:	8b 40 18             	mov    0x18(%eax),%eax
8010527d:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105284:	90                   	nop
80105285:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105288:	c9                   	leave  
80105289:	c3                   	ret    

8010528a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010528a:	55                   	push   %ebp
8010528b:	89 e5                	mov    %esp,%ebp
8010528d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105290:	83 ec 08             	sub    $0x8,%esp
80105293:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105296:	50                   	push   %eax
80105297:	ff 75 08             	pushl  0x8(%ebp)
8010529a:	e8 af fe ff ff       	call   8010514e <argint>
8010529f:	83 c4 10             	add    $0x10,%esp
801052a2:	85 c0                	test   %eax,%eax
801052a4:	79 07                	jns    801052ad <argfd+0x23>
    return -1;
801052a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ab:	eb 50                	jmp    801052fd <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801052ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052b0:	85 c0                	test   %eax,%eax
801052b2:	78 21                	js     801052d5 <argfd+0x4b>
801052b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052b7:	83 f8 0f             	cmp    $0xf,%eax
801052ba:	7f 19                	jg     801052d5 <argfd+0x4b>
801052bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052c5:	83 c2 08             	add    $0x8,%edx
801052c8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801052cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052d3:	75 07                	jne    801052dc <argfd+0x52>
    return -1;
801052d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052da:	eb 21                	jmp    801052fd <argfd+0x73>
  if(pfd)
801052dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801052e0:	74 08                	je     801052ea <argfd+0x60>
    *pfd = fd;
801052e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e8:	89 10                	mov    %edx,(%eax)
  if(pf)
801052ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052ee:	74 08                	je     801052f8 <argfd+0x6e>
    *pf = f;
801052f0:	8b 45 10             	mov    0x10(%ebp),%eax
801052f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052f6:	89 10                	mov    %edx,(%eax)
  return 0;
801052f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052fd:	c9                   	leave  
801052fe:	c3                   	ret    

801052ff <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801052ff:	55                   	push   %ebp
80105300:	89 e5                	mov    %esp,%ebp
80105302:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105305:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010530c:	eb 30                	jmp    8010533e <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
8010530e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105314:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105317:	83 c2 08             	add    $0x8,%edx
8010531a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010531e:	85 c0                	test   %eax,%eax
80105320:	75 18                	jne    8010533a <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105322:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105328:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010532b:	8d 4a 08             	lea    0x8(%edx),%ecx
8010532e:	8b 55 08             	mov    0x8(%ebp),%edx
80105331:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105335:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105338:	eb 0f                	jmp    80105349 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010533a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010533e:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105342:	7e ca                	jle    8010530e <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105344:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105349:	c9                   	leave  
8010534a:	c3                   	ret    

8010534b <sys_dup>:

int
sys_dup(void)
{
8010534b:	55                   	push   %ebp
8010534c:	89 e5                	mov    %esp,%ebp
8010534e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105351:	83 ec 04             	sub    $0x4,%esp
80105354:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105357:	50                   	push   %eax
80105358:	6a 00                	push   $0x0
8010535a:	6a 00                	push   $0x0
8010535c:	e8 29 ff ff ff       	call   8010528a <argfd>
80105361:	83 c4 10             	add    $0x10,%esp
80105364:	85 c0                	test   %eax,%eax
80105366:	79 07                	jns    8010536f <sys_dup+0x24>
    return -1;
80105368:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010536d:	eb 31                	jmp    801053a0 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010536f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105372:	83 ec 0c             	sub    $0xc,%esp
80105375:	50                   	push   %eax
80105376:	e8 84 ff ff ff       	call   801052ff <fdalloc>
8010537b:	83 c4 10             	add    $0x10,%esp
8010537e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105381:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105385:	79 07                	jns    8010538e <sys_dup+0x43>
    return -1;
80105387:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010538c:	eb 12                	jmp    801053a0 <sys_dup+0x55>
  filedup(f);
8010538e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105391:	83 ec 0c             	sub    $0xc,%esp
80105394:	50                   	push   %eax
80105395:	e8 37 bc ff ff       	call   80100fd1 <filedup>
8010539a:	83 c4 10             	add    $0x10,%esp
  return fd;
8010539d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801053a0:	c9                   	leave  
801053a1:	c3                   	ret    

801053a2 <sys_read>:

int
sys_read(void)
{
801053a2:	55                   	push   %ebp
801053a3:	89 e5                	mov    %esp,%ebp
801053a5:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053a8:	83 ec 04             	sub    $0x4,%esp
801053ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053ae:	50                   	push   %eax
801053af:	6a 00                	push   $0x0
801053b1:	6a 00                	push   $0x0
801053b3:	e8 d2 fe ff ff       	call   8010528a <argfd>
801053b8:	83 c4 10             	add    $0x10,%esp
801053bb:	85 c0                	test   %eax,%eax
801053bd:	78 2e                	js     801053ed <sys_read+0x4b>
801053bf:	83 ec 08             	sub    $0x8,%esp
801053c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053c5:	50                   	push   %eax
801053c6:	6a 02                	push   $0x2
801053c8:	e8 81 fd ff ff       	call   8010514e <argint>
801053cd:	83 c4 10             	add    $0x10,%esp
801053d0:	85 c0                	test   %eax,%eax
801053d2:	78 19                	js     801053ed <sys_read+0x4b>
801053d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053d7:	83 ec 04             	sub    $0x4,%esp
801053da:	50                   	push   %eax
801053db:	8d 45 ec             	lea    -0x14(%ebp),%eax
801053de:	50                   	push   %eax
801053df:	6a 01                	push   $0x1
801053e1:	e8 90 fd ff ff       	call   80105176 <argptr>
801053e6:	83 c4 10             	add    $0x10,%esp
801053e9:	85 c0                	test   %eax,%eax
801053eb:	79 07                	jns    801053f4 <sys_read+0x52>
    return -1;
801053ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053f2:	eb 17                	jmp    8010540b <sys_read+0x69>
  return fileread(f, p, n);
801053f4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053f7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053fd:	83 ec 04             	sub    $0x4,%esp
80105400:	51                   	push   %ecx
80105401:	52                   	push   %edx
80105402:	50                   	push   %eax
80105403:	e8 59 bd ff ff       	call   80101161 <fileread>
80105408:	83 c4 10             	add    $0x10,%esp
}
8010540b:	c9                   	leave  
8010540c:	c3                   	ret    

8010540d <sys_write>:

int
sys_write(void)
{
8010540d:	55                   	push   %ebp
8010540e:	89 e5                	mov    %esp,%ebp
80105410:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105413:	83 ec 04             	sub    $0x4,%esp
80105416:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105419:	50                   	push   %eax
8010541a:	6a 00                	push   $0x0
8010541c:	6a 00                	push   $0x0
8010541e:	e8 67 fe ff ff       	call   8010528a <argfd>
80105423:	83 c4 10             	add    $0x10,%esp
80105426:	85 c0                	test   %eax,%eax
80105428:	78 2e                	js     80105458 <sys_write+0x4b>
8010542a:	83 ec 08             	sub    $0x8,%esp
8010542d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105430:	50                   	push   %eax
80105431:	6a 02                	push   $0x2
80105433:	e8 16 fd ff ff       	call   8010514e <argint>
80105438:	83 c4 10             	add    $0x10,%esp
8010543b:	85 c0                	test   %eax,%eax
8010543d:	78 19                	js     80105458 <sys_write+0x4b>
8010543f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105442:	83 ec 04             	sub    $0x4,%esp
80105445:	50                   	push   %eax
80105446:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105449:	50                   	push   %eax
8010544a:	6a 01                	push   $0x1
8010544c:	e8 25 fd ff ff       	call   80105176 <argptr>
80105451:	83 c4 10             	add    $0x10,%esp
80105454:	85 c0                	test   %eax,%eax
80105456:	79 07                	jns    8010545f <sys_write+0x52>
    return -1;
80105458:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010545d:	eb 17                	jmp    80105476 <sys_write+0x69>
  return filewrite(f, p, n);
8010545f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105462:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105468:	83 ec 04             	sub    $0x4,%esp
8010546b:	51                   	push   %ecx
8010546c:	52                   	push   %edx
8010546d:	50                   	push   %eax
8010546e:	e8 a6 bd ff ff       	call   80101219 <filewrite>
80105473:	83 c4 10             	add    $0x10,%esp
}
80105476:	c9                   	leave  
80105477:	c3                   	ret    

80105478 <sys_close>:

int
sys_close(void)
{
80105478:	55                   	push   %ebp
80105479:	89 e5                	mov    %esp,%ebp
8010547b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010547e:	83 ec 04             	sub    $0x4,%esp
80105481:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105484:	50                   	push   %eax
80105485:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105488:	50                   	push   %eax
80105489:	6a 00                	push   $0x0
8010548b:	e8 fa fd ff ff       	call   8010528a <argfd>
80105490:	83 c4 10             	add    $0x10,%esp
80105493:	85 c0                	test   %eax,%eax
80105495:	79 07                	jns    8010549e <sys_close+0x26>
    return -1;
80105497:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010549c:	eb 28                	jmp    801054c6 <sys_close+0x4e>
  proc->ofile[fd] = 0;
8010549e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054a7:	83 c2 08             	add    $0x8,%edx
801054aa:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801054b1:	00 
  fileclose(f);
801054b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054b5:	83 ec 0c             	sub    $0xc,%esp
801054b8:	50                   	push   %eax
801054b9:	e8 64 bb ff ff       	call   80101022 <fileclose>
801054be:	83 c4 10             	add    $0x10,%esp
  return 0;
801054c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054c6:	c9                   	leave  
801054c7:	c3                   	ret    

801054c8 <sys_fstat>:

int
sys_fstat(void)
{
801054c8:	55                   	push   %ebp
801054c9:	89 e5                	mov    %esp,%ebp
801054cb:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801054ce:	83 ec 04             	sub    $0x4,%esp
801054d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054d4:	50                   	push   %eax
801054d5:	6a 00                	push   $0x0
801054d7:	6a 00                	push   $0x0
801054d9:	e8 ac fd ff ff       	call   8010528a <argfd>
801054de:	83 c4 10             	add    $0x10,%esp
801054e1:	85 c0                	test   %eax,%eax
801054e3:	78 17                	js     801054fc <sys_fstat+0x34>
801054e5:	83 ec 04             	sub    $0x4,%esp
801054e8:	6a 14                	push   $0x14
801054ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054ed:	50                   	push   %eax
801054ee:	6a 01                	push   $0x1
801054f0:	e8 81 fc ff ff       	call   80105176 <argptr>
801054f5:	83 c4 10             	add    $0x10,%esp
801054f8:	85 c0                	test   %eax,%eax
801054fa:	79 07                	jns    80105503 <sys_fstat+0x3b>
    return -1;
801054fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105501:	eb 13                	jmp    80105516 <sys_fstat+0x4e>
  return filestat(f, st);
80105503:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105509:	83 ec 08             	sub    $0x8,%esp
8010550c:	52                   	push   %edx
8010550d:	50                   	push   %eax
8010550e:	e8 f7 bb ff ff       	call   8010110a <filestat>
80105513:	83 c4 10             	add    $0x10,%esp
}
80105516:	c9                   	leave  
80105517:	c3                   	ret    

80105518 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105518:	55                   	push   %ebp
80105519:	89 e5                	mov    %esp,%ebp
8010551b:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010551e:	83 ec 08             	sub    $0x8,%esp
80105521:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105524:	50                   	push   %eax
80105525:	6a 00                	push   $0x0
80105527:	e8 a7 fc ff ff       	call   801051d3 <argstr>
8010552c:	83 c4 10             	add    $0x10,%esp
8010552f:	85 c0                	test   %eax,%eax
80105531:	78 15                	js     80105548 <sys_link+0x30>
80105533:	83 ec 08             	sub    $0x8,%esp
80105536:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105539:	50                   	push   %eax
8010553a:	6a 01                	push   $0x1
8010553c:	e8 92 fc ff ff       	call   801051d3 <argstr>
80105541:	83 c4 10             	add    $0x10,%esp
80105544:	85 c0                	test   %eax,%eax
80105546:	79 0a                	jns    80105552 <sys_link+0x3a>
    return -1;
80105548:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010554d:	e9 63 01 00 00       	jmp    801056b5 <sys_link+0x19d>
  if((ip = namei(old)) == 0)
80105552:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105555:	83 ec 0c             	sub    $0xc,%esp
80105558:	50                   	push   %eax
80105559:	e8 51 cf ff ff       	call   801024af <namei>
8010555e:	83 c4 10             	add    $0x10,%esp
80105561:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105564:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105568:	75 0a                	jne    80105574 <sys_link+0x5c>
    return -1;
8010556a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010556f:	e9 41 01 00 00       	jmp    801056b5 <sys_link+0x19d>

  begin_trans();
80105574:	e8 02 dd ff ff       	call   8010327b <begin_trans>

  ilock(ip);
80105579:	83 ec 0c             	sub    $0xc,%esp
8010557c:	ff 75 f4             	pushl  -0xc(%ebp)
8010557f:	e8 73 c3 ff ff       	call   801018f7 <ilock>
80105584:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010558a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010558e:	66 83 f8 01          	cmp    $0x1,%ax
80105592:	75 1d                	jne    801055b1 <sys_link+0x99>
    iunlockput(ip);
80105594:	83 ec 0c             	sub    $0xc,%esp
80105597:	ff 75 f4             	pushl  -0xc(%ebp)
8010559a:	e8 12 c6 ff ff       	call   80101bb1 <iunlockput>
8010559f:	83 c4 10             	add    $0x10,%esp
    commit_trans();
801055a2:	e8 27 dd ff ff       	call   801032ce <commit_trans>
    return -1;
801055a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ac:	e9 04 01 00 00       	jmp    801056b5 <sys_link+0x19d>
  }

  ip->nlink++;
801055b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801055b8:	83 c0 01             	add    $0x1,%eax
801055bb:	89 c2                	mov    %eax,%edx
801055bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c0:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801055c4:	83 ec 0c             	sub    $0xc,%esp
801055c7:	ff 75 f4             	pushl  -0xc(%ebp)
801055ca:	e8 54 c1 ff ff       	call   80101723 <iupdate>
801055cf:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801055d2:	83 ec 0c             	sub    $0xc,%esp
801055d5:	ff 75 f4             	pushl  -0xc(%ebp)
801055d8:	e8 72 c4 ff ff       	call   80101a4f <iunlock>
801055dd:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801055e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801055e3:	83 ec 08             	sub    $0x8,%esp
801055e6:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801055e9:	52                   	push   %edx
801055ea:	50                   	push   %eax
801055eb:	e8 db ce ff ff       	call   801024cb <nameiparent>
801055f0:	83 c4 10             	add    $0x10,%esp
801055f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055fa:	74 71                	je     8010566d <sys_link+0x155>
    goto bad;
  ilock(dp);
801055fc:	83 ec 0c             	sub    $0xc,%esp
801055ff:	ff 75 f0             	pushl  -0x10(%ebp)
80105602:	e8 f0 c2 ff ff       	call   801018f7 <ilock>
80105607:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010560a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010560d:	8b 10                	mov    (%eax),%edx
8010560f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105612:	8b 00                	mov    (%eax),%eax
80105614:	39 c2                	cmp    %eax,%edx
80105616:	75 1d                	jne    80105635 <sys_link+0x11d>
80105618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010561b:	8b 40 04             	mov    0x4(%eax),%eax
8010561e:	83 ec 04             	sub    $0x4,%esp
80105621:	50                   	push   %eax
80105622:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105625:	50                   	push   %eax
80105626:	ff 75 f0             	pushl  -0x10(%ebp)
80105629:	e8 e5 cb ff ff       	call   80102213 <dirlink>
8010562e:	83 c4 10             	add    $0x10,%esp
80105631:	85 c0                	test   %eax,%eax
80105633:	79 10                	jns    80105645 <sys_link+0x12d>
    iunlockput(dp);
80105635:	83 ec 0c             	sub    $0xc,%esp
80105638:	ff 75 f0             	pushl  -0x10(%ebp)
8010563b:	e8 71 c5 ff ff       	call   80101bb1 <iunlockput>
80105640:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105643:	eb 29                	jmp    8010566e <sys_link+0x156>
  }
  iunlockput(dp);
80105645:	83 ec 0c             	sub    $0xc,%esp
80105648:	ff 75 f0             	pushl  -0x10(%ebp)
8010564b:	e8 61 c5 ff ff       	call   80101bb1 <iunlockput>
80105650:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105653:	83 ec 0c             	sub    $0xc,%esp
80105656:	ff 75 f4             	pushl  -0xc(%ebp)
80105659:	e8 63 c4 ff ff       	call   80101ac1 <iput>
8010565e:	83 c4 10             	add    $0x10,%esp

  commit_trans();
80105661:	e8 68 dc ff ff       	call   801032ce <commit_trans>

  return 0;
80105666:	b8 00 00 00 00       	mov    $0x0,%eax
8010566b:	eb 48                	jmp    801056b5 <sys_link+0x19d>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
8010566d:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
8010566e:	83 ec 0c             	sub    $0xc,%esp
80105671:	ff 75 f4             	pushl  -0xc(%ebp)
80105674:	e8 7e c2 ff ff       	call   801018f7 <ilock>
80105679:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010567c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010567f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105683:	83 e8 01             	sub    $0x1,%eax
80105686:	89 c2                	mov    %eax,%edx
80105688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568b:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010568f:	83 ec 0c             	sub    $0xc,%esp
80105692:	ff 75 f4             	pushl  -0xc(%ebp)
80105695:	e8 89 c0 ff ff       	call   80101723 <iupdate>
8010569a:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010569d:	83 ec 0c             	sub    $0xc,%esp
801056a0:	ff 75 f4             	pushl  -0xc(%ebp)
801056a3:	e8 09 c5 ff ff       	call   80101bb1 <iunlockput>
801056a8:	83 c4 10             	add    $0x10,%esp
  commit_trans();
801056ab:	e8 1e dc ff ff       	call   801032ce <commit_trans>
  return -1;
801056b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056b5:	c9                   	leave  
801056b6:	c3                   	ret    

801056b7 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801056b7:	55                   	push   %ebp
801056b8:	89 e5                	mov    %esp,%ebp
801056ba:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056bd:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801056c4:	eb 40                	jmp    80105706 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801056c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c9:	6a 10                	push   $0x10
801056cb:	50                   	push   %eax
801056cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801056cf:	50                   	push   %eax
801056d0:	ff 75 08             	pushl  0x8(%ebp)
801056d3:	e8 87 c7 ff ff       	call   80101e5f <readi>
801056d8:	83 c4 10             	add    $0x10,%esp
801056db:	83 f8 10             	cmp    $0x10,%eax
801056de:	74 0d                	je     801056ed <isdirempty+0x36>
      panic("isdirempty: readi");
801056e0:	83 ec 0c             	sub    $0xc,%esp
801056e3:	68 6b 85 10 80       	push   $0x8010856b
801056e8:	e8 79 ae ff ff       	call   80100566 <panic>
    if(de.inum != 0)
801056ed:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801056f1:	66 85 c0             	test   %ax,%ax
801056f4:	74 07                	je     801056fd <isdirempty+0x46>
      return 0;
801056f6:	b8 00 00 00 00       	mov    $0x0,%eax
801056fb:	eb 1b                	jmp    80105718 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105700:	83 c0 10             	add    $0x10,%eax
80105703:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105706:	8b 45 08             	mov    0x8(%ebp),%eax
80105709:	8b 50 18             	mov    0x18(%eax),%edx
8010570c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010570f:	39 c2                	cmp    %eax,%edx
80105711:	77 b3                	ja     801056c6 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105713:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105718:	c9                   	leave  
80105719:	c3                   	ret    

8010571a <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010571a:	55                   	push   %ebp
8010571b:	89 e5                	mov    %esp,%ebp
8010571d:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105720:	83 ec 08             	sub    $0x8,%esp
80105723:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105726:	50                   	push   %eax
80105727:	6a 00                	push   $0x0
80105729:	e8 a5 fa ff ff       	call   801051d3 <argstr>
8010572e:	83 c4 10             	add    $0x10,%esp
80105731:	85 c0                	test   %eax,%eax
80105733:	79 0a                	jns    8010573f <sys_unlink+0x25>
    return -1;
80105735:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010573a:	e9 b7 01 00 00       	jmp    801058f6 <sys_unlink+0x1dc>
  if((dp = nameiparent(path, name)) == 0)
8010573f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105742:	83 ec 08             	sub    $0x8,%esp
80105745:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105748:	52                   	push   %edx
80105749:	50                   	push   %eax
8010574a:	e8 7c cd ff ff       	call   801024cb <nameiparent>
8010574f:	83 c4 10             	add    $0x10,%esp
80105752:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105755:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105759:	75 0a                	jne    80105765 <sys_unlink+0x4b>
    return -1;
8010575b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105760:	e9 91 01 00 00       	jmp    801058f6 <sys_unlink+0x1dc>

  begin_trans();
80105765:	e8 11 db ff ff       	call   8010327b <begin_trans>

  ilock(dp);
8010576a:	83 ec 0c             	sub    $0xc,%esp
8010576d:	ff 75 f4             	pushl  -0xc(%ebp)
80105770:	e8 82 c1 ff ff       	call   801018f7 <ilock>
80105775:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105778:	83 ec 08             	sub    $0x8,%esp
8010577b:	68 7d 85 10 80       	push   $0x8010857d
80105780:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105783:	50                   	push   %eax
80105784:	e8 b5 c9 ff ff       	call   8010213e <namecmp>
80105789:	83 c4 10             	add    $0x10,%esp
8010578c:	85 c0                	test   %eax,%eax
8010578e:	0f 84 4a 01 00 00    	je     801058de <sys_unlink+0x1c4>
80105794:	83 ec 08             	sub    $0x8,%esp
80105797:	68 7f 85 10 80       	push   $0x8010857f
8010579c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010579f:	50                   	push   %eax
801057a0:	e8 99 c9 ff ff       	call   8010213e <namecmp>
801057a5:	83 c4 10             	add    $0x10,%esp
801057a8:	85 c0                	test   %eax,%eax
801057aa:	0f 84 2e 01 00 00    	je     801058de <sys_unlink+0x1c4>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801057b0:	83 ec 04             	sub    $0x4,%esp
801057b3:	8d 45 c8             	lea    -0x38(%ebp),%eax
801057b6:	50                   	push   %eax
801057b7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057ba:	50                   	push   %eax
801057bb:	ff 75 f4             	pushl  -0xc(%ebp)
801057be:	e8 96 c9 ff ff       	call   80102159 <dirlookup>
801057c3:	83 c4 10             	add    $0x10,%esp
801057c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057cd:	0f 84 0a 01 00 00    	je     801058dd <sys_unlink+0x1c3>
    goto bad;
  ilock(ip);
801057d3:	83 ec 0c             	sub    $0xc,%esp
801057d6:	ff 75 f0             	pushl  -0x10(%ebp)
801057d9:	e8 19 c1 ff ff       	call   801018f7 <ilock>
801057de:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801057e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801057e8:	66 85 c0             	test   %ax,%ax
801057eb:	7f 0d                	jg     801057fa <sys_unlink+0xe0>
    panic("unlink: nlink < 1");
801057ed:	83 ec 0c             	sub    $0xc,%esp
801057f0:	68 82 85 10 80       	push   $0x80108582
801057f5:	e8 6c ad ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801057fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057fd:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105801:	66 83 f8 01          	cmp    $0x1,%ax
80105805:	75 25                	jne    8010582c <sys_unlink+0x112>
80105807:	83 ec 0c             	sub    $0xc,%esp
8010580a:	ff 75 f0             	pushl  -0x10(%ebp)
8010580d:	e8 a5 fe ff ff       	call   801056b7 <isdirempty>
80105812:	83 c4 10             	add    $0x10,%esp
80105815:	85 c0                	test   %eax,%eax
80105817:	75 13                	jne    8010582c <sys_unlink+0x112>
    iunlockput(ip);
80105819:	83 ec 0c             	sub    $0xc,%esp
8010581c:	ff 75 f0             	pushl  -0x10(%ebp)
8010581f:	e8 8d c3 ff ff       	call   80101bb1 <iunlockput>
80105824:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105827:	e9 b2 00 00 00       	jmp    801058de <sys_unlink+0x1c4>
  }

  memset(&de, 0, sizeof(de));
8010582c:	83 ec 04             	sub    $0x4,%esp
8010582f:	6a 10                	push   $0x10
80105831:	6a 00                	push   $0x0
80105833:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105836:	50                   	push   %eax
80105837:	e8 ed f5 ff ff       	call   80104e29 <memset>
8010583c:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010583f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105842:	6a 10                	push   $0x10
80105844:	50                   	push   %eax
80105845:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105848:	50                   	push   %eax
80105849:	ff 75 f4             	pushl  -0xc(%ebp)
8010584c:	e8 65 c7 ff ff       	call   80101fb6 <writei>
80105851:	83 c4 10             	add    $0x10,%esp
80105854:	83 f8 10             	cmp    $0x10,%eax
80105857:	74 0d                	je     80105866 <sys_unlink+0x14c>
    panic("unlink: writei");
80105859:	83 ec 0c             	sub    $0xc,%esp
8010585c:	68 94 85 10 80       	push   $0x80108594
80105861:	e8 00 ad ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80105866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105869:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010586d:	66 83 f8 01          	cmp    $0x1,%ax
80105871:	75 21                	jne    80105894 <sys_unlink+0x17a>
    dp->nlink--;
80105873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105876:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010587a:	83 e8 01             	sub    $0x1,%eax
8010587d:	89 c2                	mov    %eax,%edx
8010587f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105882:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105886:	83 ec 0c             	sub    $0xc,%esp
80105889:	ff 75 f4             	pushl  -0xc(%ebp)
8010588c:	e8 92 be ff ff       	call   80101723 <iupdate>
80105891:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105894:	83 ec 0c             	sub    $0xc,%esp
80105897:	ff 75 f4             	pushl  -0xc(%ebp)
8010589a:	e8 12 c3 ff ff       	call   80101bb1 <iunlockput>
8010589f:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801058a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a5:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801058a9:	83 e8 01             	sub    $0x1,%eax
801058ac:	89 c2                	mov    %eax,%edx
801058ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b1:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801058b5:	83 ec 0c             	sub    $0xc,%esp
801058b8:	ff 75 f0             	pushl  -0x10(%ebp)
801058bb:	e8 63 be ff ff       	call   80101723 <iupdate>
801058c0:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801058c3:	83 ec 0c             	sub    $0xc,%esp
801058c6:	ff 75 f0             	pushl  -0x10(%ebp)
801058c9:	e8 e3 c2 ff ff       	call   80101bb1 <iunlockput>
801058ce:	83 c4 10             	add    $0x10,%esp

  commit_trans();
801058d1:	e8 f8 d9 ff ff       	call   801032ce <commit_trans>

  return 0;
801058d6:	b8 00 00 00 00       	mov    $0x0,%eax
801058db:	eb 19                	jmp    801058f6 <sys_unlink+0x1dc>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801058dd:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
801058de:	83 ec 0c             	sub    $0xc,%esp
801058e1:	ff 75 f4             	pushl  -0xc(%ebp)
801058e4:	e8 c8 c2 ff ff       	call   80101bb1 <iunlockput>
801058e9:	83 c4 10             	add    $0x10,%esp
  commit_trans();
801058ec:	e8 dd d9 ff ff       	call   801032ce <commit_trans>
  return -1;
801058f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058f6:	c9                   	leave  
801058f7:	c3                   	ret    

801058f8 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801058f8:	55                   	push   %ebp
801058f9:	89 e5                	mov    %esp,%ebp
801058fb:	83 ec 38             	sub    $0x38,%esp
801058fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105901:	8b 55 10             	mov    0x10(%ebp),%edx
80105904:	8b 45 14             	mov    0x14(%ebp),%eax
80105907:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010590b:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010590f:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105913:	83 ec 08             	sub    $0x8,%esp
80105916:	8d 45 de             	lea    -0x22(%ebp),%eax
80105919:	50                   	push   %eax
8010591a:	ff 75 08             	pushl  0x8(%ebp)
8010591d:	e8 a9 cb ff ff       	call   801024cb <nameiparent>
80105922:	83 c4 10             	add    $0x10,%esp
80105925:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105928:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010592c:	75 0a                	jne    80105938 <create+0x40>
    return 0;
8010592e:	b8 00 00 00 00       	mov    $0x0,%eax
80105933:	e9 90 01 00 00       	jmp    80105ac8 <create+0x1d0>
  ilock(dp);
80105938:	83 ec 0c             	sub    $0xc,%esp
8010593b:	ff 75 f4             	pushl  -0xc(%ebp)
8010593e:	e8 b4 bf ff ff       	call   801018f7 <ilock>
80105943:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105946:	83 ec 04             	sub    $0x4,%esp
80105949:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010594c:	50                   	push   %eax
8010594d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105950:	50                   	push   %eax
80105951:	ff 75 f4             	pushl  -0xc(%ebp)
80105954:	e8 00 c8 ff ff       	call   80102159 <dirlookup>
80105959:	83 c4 10             	add    $0x10,%esp
8010595c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010595f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105963:	74 50                	je     801059b5 <create+0xbd>
    iunlockput(dp);
80105965:	83 ec 0c             	sub    $0xc,%esp
80105968:	ff 75 f4             	pushl  -0xc(%ebp)
8010596b:	e8 41 c2 ff ff       	call   80101bb1 <iunlockput>
80105970:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105973:	83 ec 0c             	sub    $0xc,%esp
80105976:	ff 75 f0             	pushl  -0x10(%ebp)
80105979:	e8 79 bf ff ff       	call   801018f7 <ilock>
8010597e:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105981:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105986:	75 15                	jne    8010599d <create+0xa5>
80105988:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010598b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010598f:	66 83 f8 02          	cmp    $0x2,%ax
80105993:	75 08                	jne    8010599d <create+0xa5>
      return ip;
80105995:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105998:	e9 2b 01 00 00       	jmp    80105ac8 <create+0x1d0>
    iunlockput(ip);
8010599d:	83 ec 0c             	sub    $0xc,%esp
801059a0:	ff 75 f0             	pushl  -0x10(%ebp)
801059a3:	e8 09 c2 ff ff       	call   80101bb1 <iunlockput>
801059a8:	83 c4 10             	add    $0x10,%esp
    return 0;
801059ab:	b8 00 00 00 00       	mov    $0x0,%eax
801059b0:	e9 13 01 00 00       	jmp    80105ac8 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801059b5:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801059b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059bc:	8b 00                	mov    (%eax),%eax
801059be:	83 ec 08             	sub    $0x8,%esp
801059c1:	52                   	push   %edx
801059c2:	50                   	push   %eax
801059c3:	e8 7a bc ff ff       	call   80101642 <ialloc>
801059c8:	83 c4 10             	add    $0x10,%esp
801059cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059d2:	75 0d                	jne    801059e1 <create+0xe9>
    panic("create: ialloc");
801059d4:	83 ec 0c             	sub    $0xc,%esp
801059d7:	68 a3 85 10 80       	push   $0x801085a3
801059dc:	e8 85 ab ff ff       	call   80100566 <panic>

  ilock(ip);
801059e1:	83 ec 0c             	sub    $0xc,%esp
801059e4:	ff 75 f0             	pushl  -0x10(%ebp)
801059e7:	e8 0b bf ff ff       	call   801018f7 <ilock>
801059ec:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801059ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f2:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801059f6:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801059fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059fd:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105a01:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a08:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105a0e:	83 ec 0c             	sub    $0xc,%esp
80105a11:	ff 75 f0             	pushl  -0x10(%ebp)
80105a14:	e8 0a bd ff ff       	call   80101723 <iupdate>
80105a19:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105a1c:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105a21:	75 6a                	jne    80105a8d <create+0x195>
    dp->nlink++;  // for ".."
80105a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a26:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a2a:	83 c0 01             	add    $0x1,%eax
80105a2d:	89 c2                	mov    %eax,%edx
80105a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a32:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105a36:	83 ec 0c             	sub    $0xc,%esp
80105a39:	ff 75 f4             	pushl  -0xc(%ebp)
80105a3c:	e8 e2 bc ff ff       	call   80101723 <iupdate>
80105a41:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a47:	8b 40 04             	mov    0x4(%eax),%eax
80105a4a:	83 ec 04             	sub    $0x4,%esp
80105a4d:	50                   	push   %eax
80105a4e:	68 7d 85 10 80       	push   $0x8010857d
80105a53:	ff 75 f0             	pushl  -0x10(%ebp)
80105a56:	e8 b8 c7 ff ff       	call   80102213 <dirlink>
80105a5b:	83 c4 10             	add    $0x10,%esp
80105a5e:	85 c0                	test   %eax,%eax
80105a60:	78 1e                	js     80105a80 <create+0x188>
80105a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a65:	8b 40 04             	mov    0x4(%eax),%eax
80105a68:	83 ec 04             	sub    $0x4,%esp
80105a6b:	50                   	push   %eax
80105a6c:	68 7f 85 10 80       	push   $0x8010857f
80105a71:	ff 75 f0             	pushl  -0x10(%ebp)
80105a74:	e8 9a c7 ff ff       	call   80102213 <dirlink>
80105a79:	83 c4 10             	add    $0x10,%esp
80105a7c:	85 c0                	test   %eax,%eax
80105a7e:	79 0d                	jns    80105a8d <create+0x195>
      panic("create dots");
80105a80:	83 ec 0c             	sub    $0xc,%esp
80105a83:	68 b2 85 10 80       	push   $0x801085b2
80105a88:	e8 d9 aa ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a90:	8b 40 04             	mov    0x4(%eax),%eax
80105a93:	83 ec 04             	sub    $0x4,%esp
80105a96:	50                   	push   %eax
80105a97:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a9a:	50                   	push   %eax
80105a9b:	ff 75 f4             	pushl  -0xc(%ebp)
80105a9e:	e8 70 c7 ff ff       	call   80102213 <dirlink>
80105aa3:	83 c4 10             	add    $0x10,%esp
80105aa6:	85 c0                	test   %eax,%eax
80105aa8:	79 0d                	jns    80105ab7 <create+0x1bf>
    panic("create: dirlink");
80105aaa:	83 ec 0c             	sub    $0xc,%esp
80105aad:	68 be 85 10 80       	push   $0x801085be
80105ab2:	e8 af aa ff ff       	call   80100566 <panic>

  iunlockput(dp);
80105ab7:	83 ec 0c             	sub    $0xc,%esp
80105aba:	ff 75 f4             	pushl  -0xc(%ebp)
80105abd:	e8 ef c0 ff ff       	call   80101bb1 <iunlockput>
80105ac2:	83 c4 10             	add    $0x10,%esp

  return ip;
80105ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105ac8:	c9                   	leave  
80105ac9:	c3                   	ret    

80105aca <sys_open>:

int
sys_open(void)
{
80105aca:	55                   	push   %ebp
80105acb:	89 e5                	mov    %esp,%ebp
80105acd:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105ad0:	83 ec 08             	sub    $0x8,%esp
80105ad3:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ad6:	50                   	push   %eax
80105ad7:	6a 00                	push   $0x0
80105ad9:	e8 f5 f6 ff ff       	call   801051d3 <argstr>
80105ade:	83 c4 10             	add    $0x10,%esp
80105ae1:	85 c0                	test   %eax,%eax
80105ae3:	78 15                	js     80105afa <sys_open+0x30>
80105ae5:	83 ec 08             	sub    $0x8,%esp
80105ae8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105aeb:	50                   	push   %eax
80105aec:	6a 01                	push   $0x1
80105aee:	e8 5b f6 ff ff       	call   8010514e <argint>
80105af3:	83 c4 10             	add    $0x10,%esp
80105af6:	85 c0                	test   %eax,%eax
80105af8:	79 0a                	jns    80105b04 <sys_open+0x3a>
    return -1;
80105afa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aff:	e9 4d 01 00 00       	jmp    80105c51 <sys_open+0x187>
  if(omode & O_CREATE){
80105b04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b07:	25 00 02 00 00       	and    $0x200,%eax
80105b0c:	85 c0                	test   %eax,%eax
80105b0e:	74 2f                	je     80105b3f <sys_open+0x75>
    begin_trans();
80105b10:	e8 66 d7 ff ff       	call   8010327b <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80105b15:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b18:	6a 00                	push   $0x0
80105b1a:	6a 00                	push   $0x0
80105b1c:	6a 02                	push   $0x2
80105b1e:	50                   	push   %eax
80105b1f:	e8 d4 fd ff ff       	call   801058f8 <create>
80105b24:	83 c4 10             	add    $0x10,%esp
80105b27:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80105b2a:	e8 9f d7 ff ff       	call   801032ce <commit_trans>
    if(ip == 0)
80105b2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b33:	75 66                	jne    80105b9b <sys_open+0xd1>
      return -1;
80105b35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b3a:	e9 12 01 00 00       	jmp    80105c51 <sys_open+0x187>
  } else {
    if((ip = namei(path)) == 0)
80105b3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b42:	83 ec 0c             	sub    $0xc,%esp
80105b45:	50                   	push   %eax
80105b46:	e8 64 c9 ff ff       	call   801024af <namei>
80105b4b:	83 c4 10             	add    $0x10,%esp
80105b4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b55:	75 0a                	jne    80105b61 <sys_open+0x97>
      return -1;
80105b57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5c:	e9 f0 00 00 00       	jmp    80105c51 <sys_open+0x187>
    ilock(ip);
80105b61:	83 ec 0c             	sub    $0xc,%esp
80105b64:	ff 75 f4             	pushl  -0xc(%ebp)
80105b67:	e8 8b bd ff ff       	call   801018f7 <ilock>
80105b6c:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b72:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b76:	66 83 f8 01          	cmp    $0x1,%ax
80105b7a:	75 1f                	jne    80105b9b <sys_open+0xd1>
80105b7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b7f:	85 c0                	test   %eax,%eax
80105b81:	74 18                	je     80105b9b <sys_open+0xd1>
      iunlockput(ip);
80105b83:	83 ec 0c             	sub    $0xc,%esp
80105b86:	ff 75 f4             	pushl  -0xc(%ebp)
80105b89:	e8 23 c0 ff ff       	call   80101bb1 <iunlockput>
80105b8e:	83 c4 10             	add    $0x10,%esp
      return -1;
80105b91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b96:	e9 b6 00 00 00       	jmp    80105c51 <sys_open+0x187>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105b9b:	e8 c4 b3 ff ff       	call   80100f64 <filealloc>
80105ba0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ba3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ba7:	74 17                	je     80105bc0 <sys_open+0xf6>
80105ba9:	83 ec 0c             	sub    $0xc,%esp
80105bac:	ff 75 f0             	pushl  -0x10(%ebp)
80105baf:	e8 4b f7 ff ff       	call   801052ff <fdalloc>
80105bb4:	83 c4 10             	add    $0x10,%esp
80105bb7:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105bba:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105bbe:	79 29                	jns    80105be9 <sys_open+0x11f>
    if(f)
80105bc0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bc4:	74 0e                	je     80105bd4 <sys_open+0x10a>
      fileclose(f);
80105bc6:	83 ec 0c             	sub    $0xc,%esp
80105bc9:	ff 75 f0             	pushl  -0x10(%ebp)
80105bcc:	e8 51 b4 ff ff       	call   80101022 <fileclose>
80105bd1:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105bd4:	83 ec 0c             	sub    $0xc,%esp
80105bd7:	ff 75 f4             	pushl  -0xc(%ebp)
80105bda:	e8 d2 bf ff ff       	call   80101bb1 <iunlockput>
80105bdf:	83 c4 10             	add    $0x10,%esp
    return -1;
80105be2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be7:	eb 68                	jmp    80105c51 <sys_open+0x187>
  }
  iunlock(ip);
80105be9:	83 ec 0c             	sub    $0xc,%esp
80105bec:	ff 75 f4             	pushl  -0xc(%ebp)
80105bef:	e8 5b be ff ff       	call   80101a4f <iunlock>
80105bf4:	83 c4 10             	add    $0x10,%esp

  f->type = FD_INODE;
80105bf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bfa:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c06:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105c09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c0c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105c13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c16:	83 e0 01             	and    $0x1,%eax
80105c19:	85 c0                	test   %eax,%eax
80105c1b:	0f 94 c0             	sete   %al
80105c1e:	89 c2                	mov    %eax,%edx
80105c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c23:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105c26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c29:	83 e0 01             	and    $0x1,%eax
80105c2c:	85 c0                	test   %eax,%eax
80105c2e:	75 0a                	jne    80105c3a <sys_open+0x170>
80105c30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c33:	83 e0 02             	and    $0x2,%eax
80105c36:	85 c0                	test   %eax,%eax
80105c38:	74 07                	je     80105c41 <sys_open+0x177>
80105c3a:	b8 01 00 00 00       	mov    $0x1,%eax
80105c3f:	eb 05                	jmp    80105c46 <sys_open+0x17c>
80105c41:	b8 00 00 00 00       	mov    $0x0,%eax
80105c46:	89 c2                	mov    %eax,%edx
80105c48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c4b:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105c4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105c51:	c9                   	leave  
80105c52:	c3                   	ret    

80105c53 <sys_mkdir>:

int
sys_mkdir(void)
{
80105c53:	55                   	push   %ebp
80105c54:	89 e5                	mov    %esp,%ebp
80105c56:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_trans();
80105c59:	e8 1d d6 ff ff       	call   8010327b <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105c5e:	83 ec 08             	sub    $0x8,%esp
80105c61:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c64:	50                   	push   %eax
80105c65:	6a 00                	push   $0x0
80105c67:	e8 67 f5 ff ff       	call   801051d3 <argstr>
80105c6c:	83 c4 10             	add    $0x10,%esp
80105c6f:	85 c0                	test   %eax,%eax
80105c71:	78 1b                	js     80105c8e <sys_mkdir+0x3b>
80105c73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c76:	6a 00                	push   $0x0
80105c78:	6a 00                	push   $0x0
80105c7a:	6a 01                	push   $0x1
80105c7c:	50                   	push   %eax
80105c7d:	e8 76 fc ff ff       	call   801058f8 <create>
80105c82:	83 c4 10             	add    $0x10,%esp
80105c85:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c88:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c8c:	75 0c                	jne    80105c9a <sys_mkdir+0x47>
    commit_trans();
80105c8e:	e8 3b d6 ff ff       	call   801032ce <commit_trans>
    return -1;
80105c93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c98:	eb 18                	jmp    80105cb2 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105c9a:	83 ec 0c             	sub    $0xc,%esp
80105c9d:	ff 75 f4             	pushl  -0xc(%ebp)
80105ca0:	e8 0c bf ff ff       	call   80101bb1 <iunlockput>
80105ca5:	83 c4 10             	add    $0x10,%esp
  commit_trans();
80105ca8:	e8 21 d6 ff ff       	call   801032ce <commit_trans>
  return 0;
80105cad:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cb2:	c9                   	leave  
80105cb3:	c3                   	ret    

80105cb4 <sys_mknod>:

int
sys_mknod(void)
{
80105cb4:	55                   	push   %ebp
80105cb5:	89 e5                	mov    %esp,%ebp
80105cb7:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80105cba:	e8 bc d5 ff ff       	call   8010327b <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80105cbf:	83 ec 08             	sub    $0x8,%esp
80105cc2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cc5:	50                   	push   %eax
80105cc6:	6a 00                	push   $0x0
80105cc8:	e8 06 f5 ff ff       	call   801051d3 <argstr>
80105ccd:	83 c4 10             	add    $0x10,%esp
80105cd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cd3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cd7:	78 4f                	js     80105d28 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80105cd9:	83 ec 08             	sub    $0x8,%esp
80105cdc:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105cdf:	50                   	push   %eax
80105ce0:	6a 01                	push   $0x1
80105ce2:	e8 67 f4 ff ff       	call   8010514e <argint>
80105ce7:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
80105cea:	85 c0                	test   %eax,%eax
80105cec:	78 3a                	js     80105d28 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105cee:	83 ec 08             	sub    $0x8,%esp
80105cf1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105cf4:	50                   	push   %eax
80105cf5:	6a 02                	push   $0x2
80105cf7:	e8 52 f4 ff ff       	call   8010514e <argint>
80105cfc:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80105cff:	85 c0                	test   %eax,%eax
80105d01:	78 25                	js     80105d28 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80105d03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d06:	0f bf c8             	movswl %ax,%ecx
80105d09:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d0c:	0f bf d0             	movswl %ax,%edx
80105d0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105d12:	51                   	push   %ecx
80105d13:	52                   	push   %edx
80105d14:	6a 03                	push   $0x3
80105d16:	50                   	push   %eax
80105d17:	e8 dc fb ff ff       	call   801058f8 <create>
80105d1c:	83 c4 10             	add    $0x10,%esp
80105d1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d26:	75 0c                	jne    80105d34 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
80105d28:	e8 a1 d5 ff ff       	call   801032ce <commit_trans>
    return -1;
80105d2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d32:	eb 18                	jmp    80105d4c <sys_mknod+0x98>
  }
  iunlockput(ip);
80105d34:	83 ec 0c             	sub    $0xc,%esp
80105d37:	ff 75 f0             	pushl  -0x10(%ebp)
80105d3a:	e8 72 be ff ff       	call   80101bb1 <iunlockput>
80105d3f:	83 c4 10             	add    $0x10,%esp
  commit_trans();
80105d42:	e8 87 d5 ff ff       	call   801032ce <commit_trans>
  return 0;
80105d47:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d4c:	c9                   	leave  
80105d4d:	c3                   	ret    

80105d4e <sys_chdir>:

int
sys_chdir(void)
{
80105d4e:	55                   	push   %ebp
80105d4f:	89 e5                	mov    %esp,%ebp
80105d51:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
80105d54:	83 ec 08             	sub    $0x8,%esp
80105d57:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d5a:	50                   	push   %eax
80105d5b:	6a 00                	push   $0x0
80105d5d:	e8 71 f4 ff ff       	call   801051d3 <argstr>
80105d62:	83 c4 10             	add    $0x10,%esp
80105d65:	85 c0                	test   %eax,%eax
80105d67:	78 18                	js     80105d81 <sys_chdir+0x33>
80105d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d6c:	83 ec 0c             	sub    $0xc,%esp
80105d6f:	50                   	push   %eax
80105d70:	e8 3a c7 ff ff       	call   801024af <namei>
80105d75:	83 c4 10             	add    $0x10,%esp
80105d78:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d7f:	75 07                	jne    80105d88 <sys_chdir+0x3a>
    return -1;
80105d81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d86:	eb 64                	jmp    80105dec <sys_chdir+0x9e>
  ilock(ip);
80105d88:	83 ec 0c             	sub    $0xc,%esp
80105d8b:	ff 75 f4             	pushl  -0xc(%ebp)
80105d8e:	e8 64 bb ff ff       	call   801018f7 <ilock>
80105d93:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d99:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d9d:	66 83 f8 01          	cmp    $0x1,%ax
80105da1:	74 15                	je     80105db8 <sys_chdir+0x6a>
    iunlockput(ip);
80105da3:	83 ec 0c             	sub    $0xc,%esp
80105da6:	ff 75 f4             	pushl  -0xc(%ebp)
80105da9:	e8 03 be ff ff       	call   80101bb1 <iunlockput>
80105dae:	83 c4 10             	add    $0x10,%esp
    return -1;
80105db1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105db6:	eb 34                	jmp    80105dec <sys_chdir+0x9e>
  }
  iunlock(ip);
80105db8:	83 ec 0c             	sub    $0xc,%esp
80105dbb:	ff 75 f4             	pushl  -0xc(%ebp)
80105dbe:	e8 8c bc ff ff       	call   80101a4f <iunlock>
80105dc3:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80105dc6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105dcc:	8b 40 68             	mov    0x68(%eax),%eax
80105dcf:	83 ec 0c             	sub    $0xc,%esp
80105dd2:	50                   	push   %eax
80105dd3:	e8 e9 bc ff ff       	call   80101ac1 <iput>
80105dd8:	83 c4 10             	add    $0x10,%esp
  proc->cwd = ip;
80105ddb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105de1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105de4:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105de7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dec:	c9                   	leave  
80105ded:	c3                   	ret    

80105dee <sys_exec>:

int
sys_exec(void)
{
80105dee:	55                   	push   %ebp
80105def:	89 e5                	mov    %esp,%ebp
80105df1:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105df7:	83 ec 08             	sub    $0x8,%esp
80105dfa:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105dfd:	50                   	push   %eax
80105dfe:	6a 00                	push   $0x0
80105e00:	e8 ce f3 ff ff       	call   801051d3 <argstr>
80105e05:	83 c4 10             	add    $0x10,%esp
80105e08:	85 c0                	test   %eax,%eax
80105e0a:	78 18                	js     80105e24 <sys_exec+0x36>
80105e0c:	83 ec 08             	sub    $0x8,%esp
80105e0f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105e15:	50                   	push   %eax
80105e16:	6a 01                	push   $0x1
80105e18:	e8 31 f3 ff ff       	call   8010514e <argint>
80105e1d:	83 c4 10             	add    $0x10,%esp
80105e20:	85 c0                	test   %eax,%eax
80105e22:	79 0a                	jns    80105e2e <sys_exec+0x40>
    return -1;
80105e24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e29:	e9 c6 00 00 00       	jmp    80105ef4 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105e2e:	83 ec 04             	sub    $0x4,%esp
80105e31:	68 80 00 00 00       	push   $0x80
80105e36:	6a 00                	push   $0x0
80105e38:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e3e:	50                   	push   %eax
80105e3f:	e8 e5 ef ff ff       	call   80104e29 <memset>
80105e44:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105e47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e51:	83 f8 1f             	cmp    $0x1f,%eax
80105e54:	76 0a                	jbe    80105e60 <sys_exec+0x72>
      return -1;
80105e56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e5b:	e9 94 00 00 00       	jmp    80105ef4 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e63:	c1 e0 02             	shl    $0x2,%eax
80105e66:	89 c2                	mov    %eax,%edx
80105e68:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105e6e:	01 c2                	add    %eax,%edx
80105e70:	83 ec 08             	sub    $0x8,%esp
80105e73:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105e79:	50                   	push   %eax
80105e7a:	52                   	push   %edx
80105e7b:	e8 32 f2 ff ff       	call   801050b2 <fetchint>
80105e80:	83 c4 10             	add    $0x10,%esp
80105e83:	85 c0                	test   %eax,%eax
80105e85:	79 07                	jns    80105e8e <sys_exec+0xa0>
      return -1;
80105e87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e8c:	eb 66                	jmp    80105ef4 <sys_exec+0x106>
    if(uarg == 0){
80105e8e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e94:	85 c0                	test   %eax,%eax
80105e96:	75 27                	jne    80105ebf <sys_exec+0xd1>
      argv[i] = 0;
80105e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e9b:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105ea2:	00 00 00 00 
      break;
80105ea6:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105ea7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eaa:	83 ec 08             	sub    $0x8,%esp
80105ead:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105eb3:	52                   	push   %edx
80105eb4:	50                   	push   %eax
80105eb5:	e8 9c ac ff ff       	call   80100b56 <exec>
80105eba:	83 c4 10             	add    $0x10,%esp
80105ebd:	eb 35                	jmp    80105ef4 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105ebf:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105ec5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ec8:	c1 e2 02             	shl    $0x2,%edx
80105ecb:	01 c2                	add    %eax,%edx
80105ecd:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105ed3:	83 ec 08             	sub    $0x8,%esp
80105ed6:	52                   	push   %edx
80105ed7:	50                   	push   %eax
80105ed8:	e8 0f f2 ff ff       	call   801050ec <fetchstr>
80105edd:	83 c4 10             	add    $0x10,%esp
80105ee0:	85 c0                	test   %eax,%eax
80105ee2:	79 07                	jns    80105eeb <sys_exec+0xfd>
      return -1;
80105ee4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ee9:	eb 09                	jmp    80105ef4 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80105eeb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80105eef:	e9 5a ff ff ff       	jmp    80105e4e <sys_exec+0x60>
  return exec(path, argv);
}
80105ef4:	c9                   	leave  
80105ef5:	c3                   	ret    

80105ef6 <sys_pipe>:

int
sys_pipe(void)
{
80105ef6:	55                   	push   %ebp
80105ef7:	89 e5                	mov    %esp,%ebp
80105ef9:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105efc:	83 ec 04             	sub    $0x4,%esp
80105eff:	6a 08                	push   $0x8
80105f01:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f04:	50                   	push   %eax
80105f05:	6a 00                	push   $0x0
80105f07:	e8 6a f2 ff ff       	call   80105176 <argptr>
80105f0c:	83 c4 10             	add    $0x10,%esp
80105f0f:	85 c0                	test   %eax,%eax
80105f11:	79 0a                	jns    80105f1d <sys_pipe+0x27>
    return -1;
80105f13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f18:	e9 af 00 00 00       	jmp    80105fcc <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80105f1d:	83 ec 08             	sub    $0x8,%esp
80105f20:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f23:	50                   	push   %eax
80105f24:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f27:	50                   	push   %eax
80105f28:	e8 1a dd ff ff       	call   80103c47 <pipealloc>
80105f2d:	83 c4 10             	add    $0x10,%esp
80105f30:	85 c0                	test   %eax,%eax
80105f32:	79 0a                	jns    80105f3e <sys_pipe+0x48>
    return -1;
80105f34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f39:	e9 8e 00 00 00       	jmp    80105fcc <sys_pipe+0xd6>
  fd0 = -1;
80105f3e:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105f45:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f48:	83 ec 0c             	sub    $0xc,%esp
80105f4b:	50                   	push   %eax
80105f4c:	e8 ae f3 ff ff       	call   801052ff <fdalloc>
80105f51:	83 c4 10             	add    $0x10,%esp
80105f54:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f5b:	78 18                	js     80105f75 <sys_pipe+0x7f>
80105f5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f60:	83 ec 0c             	sub    $0xc,%esp
80105f63:	50                   	push   %eax
80105f64:	e8 96 f3 ff ff       	call   801052ff <fdalloc>
80105f69:	83 c4 10             	add    $0x10,%esp
80105f6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f73:	79 3f                	jns    80105fb4 <sys_pipe+0xbe>
    if(fd0 >= 0)
80105f75:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f79:	78 14                	js     80105f8f <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80105f7b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f81:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f84:	83 c2 08             	add    $0x8,%edx
80105f87:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105f8e:	00 
    fileclose(rf);
80105f8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f92:	83 ec 0c             	sub    $0xc,%esp
80105f95:	50                   	push   %eax
80105f96:	e8 87 b0 ff ff       	call   80101022 <fileclose>
80105f9b:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105f9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fa1:	83 ec 0c             	sub    $0xc,%esp
80105fa4:	50                   	push   %eax
80105fa5:	e8 78 b0 ff ff       	call   80101022 <fileclose>
80105faa:	83 c4 10             	add    $0x10,%esp
    return -1;
80105fad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb2:	eb 18                	jmp    80105fcc <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80105fb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fb7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fba:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105fbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fbf:	8d 50 04             	lea    0x4(%eax),%edx
80105fc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc5:	89 02                	mov    %eax,(%edx)
  return 0;
80105fc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fcc:	c9                   	leave  
80105fcd:	c3                   	ret    

80105fce <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105fce:	55                   	push   %ebp
80105fcf:	89 e5                	mov    %esp,%ebp
80105fd1:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105fd4:	e8 64 e3 ff ff       	call   8010433d <fork>
}
80105fd9:	c9                   	leave  
80105fda:	c3                   	ret    

80105fdb <sys_exit>:

int
sys_exit(void)
{
80105fdb:	55                   	push   %ebp
80105fdc:	89 e5                	mov    %esp,%ebp
80105fde:	83 ec 08             	sub    $0x8,%esp
  exit();
80105fe1:	e8 c8 e4 ff ff       	call   801044ae <exit>
  return 0;  // not reached
80105fe6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105feb:	c9                   	leave  
80105fec:	c3                   	ret    

80105fed <sys_wait>:

int
sys_wait(void)
{
80105fed:	55                   	push   %ebp
80105fee:	89 e5                	mov    %esp,%ebp
80105ff0:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105ff3:	e8 e4 e5 ff ff       	call   801045dc <wait>
}
80105ff8:	c9                   	leave  
80105ff9:	c3                   	ret    

80105ffa <sys_kill>:

int
sys_kill(void)
{
80105ffa:	55                   	push   %ebp
80105ffb:	89 e5                	mov    %esp,%ebp
80105ffd:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106000:	83 ec 08             	sub    $0x8,%esp
80106003:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106006:	50                   	push   %eax
80106007:	6a 00                	push   $0x0
80106009:	e8 40 f1 ff ff       	call   8010514e <argint>
8010600e:	83 c4 10             	add    $0x10,%esp
80106011:	85 c0                	test   %eax,%eax
80106013:	79 07                	jns    8010601c <sys_kill+0x22>
    return -1;
80106015:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010601a:	eb 0f                	jmp    8010602b <sys_kill+0x31>
  return kill(pid);
8010601c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010601f:	83 ec 0c             	sub    $0xc,%esp
80106022:	50                   	push   %eax
80106023:	e8 c7 e9 ff ff       	call   801049ef <kill>
80106028:	83 c4 10             	add    $0x10,%esp
}
8010602b:	c9                   	leave  
8010602c:	c3                   	ret    

8010602d <sys_getpid>:

int
sys_getpid(void)
{
8010602d:	55                   	push   %ebp
8010602e:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106030:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106036:	8b 40 10             	mov    0x10(%eax),%eax
}
80106039:	5d                   	pop    %ebp
8010603a:	c3                   	ret    

8010603b <sys_sbrk>:

int
sys_sbrk(void)
{
8010603b:	55                   	push   %ebp
8010603c:	89 e5                	mov    %esp,%ebp
8010603e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106041:	83 ec 08             	sub    $0x8,%esp
80106044:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106047:	50                   	push   %eax
80106048:	6a 00                	push   $0x0
8010604a:	e8 ff f0 ff ff       	call   8010514e <argint>
8010604f:	83 c4 10             	add    $0x10,%esp
80106052:	85 c0                	test   %eax,%eax
80106054:	79 07                	jns    8010605d <sys_sbrk+0x22>
    return -1;
80106056:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010605b:	eb 28                	jmp    80106085 <sys_sbrk+0x4a>
  addr = proc->sz;
8010605d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106063:	8b 00                	mov    (%eax),%eax
80106065:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106068:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010606b:	83 ec 0c             	sub    $0xc,%esp
8010606e:	50                   	push   %eax
8010606f:	e8 26 e2 ff ff       	call   8010429a <growproc>
80106074:	83 c4 10             	add    $0x10,%esp
80106077:	85 c0                	test   %eax,%eax
80106079:	79 07                	jns    80106082 <sys_sbrk+0x47>
    return -1;
8010607b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106080:	eb 03                	jmp    80106085 <sys_sbrk+0x4a>
  return addr;
80106082:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106085:	c9                   	leave  
80106086:	c3                   	ret    

80106087 <sys_sleep>:

int
sys_sleep(void)
{
80106087:	55                   	push   %ebp
80106088:	89 e5                	mov    %esp,%ebp
8010608a:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010608d:	83 ec 08             	sub    $0x8,%esp
80106090:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106093:	50                   	push   %eax
80106094:	6a 00                	push   $0x0
80106096:	e8 b3 f0 ff ff       	call   8010514e <argint>
8010609b:	83 c4 10             	add    $0x10,%esp
8010609e:	85 c0                	test   %eax,%eax
801060a0:	79 07                	jns    801060a9 <sys_sleep+0x22>
    return -1;
801060a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a7:	eb 77                	jmp    80106120 <sys_sleep+0x99>
  acquire(&tickslock);
801060a9:	83 ec 0c             	sub    $0xc,%esp
801060ac:	68 a0 1e 11 80       	push   $0x80111ea0
801060b1:	e8 10 eb ff ff       	call   80104bc6 <acquire>
801060b6:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801060b9:	a1 e0 26 11 80       	mov    0x801126e0,%eax
801060be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801060c1:	eb 39                	jmp    801060fc <sys_sleep+0x75>
    if(proc->killed){
801060c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060c9:	8b 40 24             	mov    0x24(%eax),%eax
801060cc:	85 c0                	test   %eax,%eax
801060ce:	74 17                	je     801060e7 <sys_sleep+0x60>
      release(&tickslock);
801060d0:	83 ec 0c             	sub    $0xc,%esp
801060d3:	68 a0 1e 11 80       	push   $0x80111ea0
801060d8:	e8 50 eb ff ff       	call   80104c2d <release>
801060dd:	83 c4 10             	add    $0x10,%esp
      return -1;
801060e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e5:	eb 39                	jmp    80106120 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
801060e7:	83 ec 08             	sub    $0x8,%esp
801060ea:	68 a0 1e 11 80       	push   $0x80111ea0
801060ef:	68 e0 26 11 80       	push   $0x801126e0
801060f4:	e8 d4 e7 ff ff       	call   801048cd <sleep>
801060f9:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801060fc:	a1 e0 26 11 80       	mov    0x801126e0,%eax
80106101:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106104:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106107:	39 d0                	cmp    %edx,%eax
80106109:	72 b8                	jb     801060c3 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
8010610b:	83 ec 0c             	sub    $0xc,%esp
8010610e:	68 a0 1e 11 80       	push   $0x80111ea0
80106113:	e8 15 eb ff ff       	call   80104c2d <release>
80106118:	83 c4 10             	add    $0x10,%esp
  return 0;
8010611b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106120:	c9                   	leave  
80106121:	c3                   	ret    

80106122 <sys_incrementMagic>:

int
sys_incrementMagic(void) {
80106122:	55                   	push   %ebp
80106123:	89 e5                	mov    %esp,%ebp
80106125:	83 ec 18             	sub    $0x18,%esp
    int value;
    if(argint(0,&value)<0)
80106128:	83 ec 08             	sub    $0x8,%esp
8010612b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010612e:	50                   	push   %eax
8010612f:	6a 00                	push   $0x0
80106131:	e8 18 f0 ff ff       	call   8010514e <argint>
80106136:	83 c4 10             	add    $0x10,%esp
80106139:	85 c0                	test   %eax,%eax
8010613b:	79 07                	jns    80106144 <sys_incrementMagic+0x22>
        return -1;
8010613d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106142:	eb 23                	jmp    80106167 <sys_incrementMagic+0x45>
    cpu->magic = cpu->magic + value;
80106144:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010614a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106151:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
80106157:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010615a:	01 ca                	add    %ecx,%edx
8010615c:	89 90 b4 00 00 00    	mov    %edx,0xb4(%eax)
    return 0;
80106162:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106167:	c9                   	leave  
80106168:	c3                   	ret    

80106169 <sys_getMagic>:

int 
sys_getMagic(void) {
80106169:	55                   	push   %ebp
8010616a:	89 e5                	mov    %esp,%ebp
    return cpu->magic;
8010616c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106172:	8b 80 b4 00 00 00    	mov    0xb4(%eax),%eax
}
80106178:	5d                   	pop    %ebp
80106179:	c3                   	ret    

8010617a <sys_getCurrentProcessName>:

int
sys_getCurrentProcessName(void) {
8010617a:	55                   	push   %ebp
8010617b:	89 e5                	mov    %esp,%ebp
8010617d:	83 ec 08             	sub    $0x8,%esp
    cprintf("%s\n",proc->name);
80106180:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106186:	83 c0 6c             	add    $0x6c,%eax
80106189:	83 ec 08             	sub    $0x8,%esp
8010618c:	50                   	push   %eax
8010618d:	68 ce 85 10 80       	push   $0x801085ce
80106192:	e8 2f a2 ff ff       	call   801003c6 <cprintf>
80106197:	83 c4 10             	add    $0x10,%esp
    return 0;
8010619a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010619f:	c9                   	leave  
801061a0:	c3                   	ret    

801061a1 <sys_modifyCurrentProcessName>:

int
sys_modifyCurrentProcessName(void) {
801061a1:	55                   	push   %ebp
801061a2:	89 e5                	mov    %esp,%ebp
801061a4:	83 ec 18             	sub    $0x18,%esp
    char* newName;
    if (argstr(0,&newName) < 0)
801061a7:	83 ec 08             	sub    $0x8,%esp
801061aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061ad:	50                   	push   %eax
801061ae:	6a 00                	push   $0x0
801061b0:	e8 1e f0 ff ff       	call   801051d3 <argstr>
801061b5:	83 c4 10             	add    $0x10,%esp
801061b8:	85 c0                	test   %eax,%eax
801061ba:	79 07                	jns    801061c3 <sys_modifyCurrentProcessName+0x22>
        return -1;
801061bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c1:	eb 21                	jmp    801061e4 <sys_modifyCurrentProcessName+0x43>
    strncpy(proc->name, newName, 16);
801061c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801061cd:	83 c2 6c             	add    $0x6c,%edx
801061d0:	83 ec 04             	sub    $0x4,%esp
801061d3:	6a 10                	push   $0x10
801061d5:	50                   	push   %eax
801061d6:	52                   	push   %edx
801061d7:	e8 f8 ed ff ff       	call   80104fd4 <strncpy>
801061dc:	83 c4 10             	add    $0x10,%esp
    return 0;
801061df:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061e4:	c9                   	leave  
801061e5:	c3                   	ret    

801061e6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801061e6:	55                   	push   %ebp
801061e7:	89 e5                	mov    %esp,%ebp
801061e9:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
801061ec:	83 ec 0c             	sub    $0xc,%esp
801061ef:	68 a0 1e 11 80       	push   $0x80111ea0
801061f4:	e8 cd e9 ff ff       	call   80104bc6 <acquire>
801061f9:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801061fc:	a1 e0 26 11 80       	mov    0x801126e0,%eax
80106201:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106204:	83 ec 0c             	sub    $0xc,%esp
80106207:	68 a0 1e 11 80       	push   $0x80111ea0
8010620c:	e8 1c ea ff ff       	call   80104c2d <release>
80106211:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106214:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106217:	c9                   	leave  
80106218:	c3                   	ret    

80106219 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106219:	55                   	push   %ebp
8010621a:	89 e5                	mov    %esp,%ebp
8010621c:	83 ec 08             	sub    $0x8,%esp
8010621f:	8b 55 08             	mov    0x8(%ebp),%edx
80106222:	8b 45 0c             	mov    0xc(%ebp),%eax
80106225:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106229:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010622c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106230:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106234:	ee                   	out    %al,(%dx)
}
80106235:	90                   	nop
80106236:	c9                   	leave  
80106237:	c3                   	ret    

80106238 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106238:	55                   	push   %ebp
80106239:	89 e5                	mov    %esp,%ebp
8010623b:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010623e:	6a 34                	push   $0x34
80106240:	6a 43                	push   $0x43
80106242:	e8 d2 ff ff ff       	call   80106219 <outb>
80106247:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010624a:	68 9c 00 00 00       	push   $0x9c
8010624f:	6a 40                	push   $0x40
80106251:	e8 c3 ff ff ff       	call   80106219 <outb>
80106256:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106259:	6a 2e                	push   $0x2e
8010625b:	6a 40                	push   $0x40
8010625d:	e8 b7 ff ff ff       	call   80106219 <outb>
80106262:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80106265:	83 ec 0c             	sub    $0xc,%esp
80106268:	6a 00                	push   $0x0
8010626a:	e8 c2 d8 ff ff       	call   80103b31 <picenable>
8010626f:	83 c4 10             	add    $0x10,%esp
}
80106272:	90                   	nop
80106273:	c9                   	leave  
80106274:	c3                   	ret    

80106275 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106275:	1e                   	push   %ds
  pushl %es
80106276:	06                   	push   %es
  pushl %fs
80106277:	0f a0                	push   %fs
  pushl %gs
80106279:	0f a8                	push   %gs
  pushal
8010627b:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010627c:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106280:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106282:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106284:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106288:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010628a:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010628c:	54                   	push   %esp
  call trap
8010628d:	e8 d7 01 00 00       	call   80106469 <trap>
  addl $4, %esp
80106292:	83 c4 04             	add    $0x4,%esp

80106295 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106295:	61                   	popa   
  popl %gs
80106296:	0f a9                	pop    %gs
  popl %fs
80106298:	0f a1                	pop    %fs
  popl %es
8010629a:	07                   	pop    %es
  popl %ds
8010629b:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010629c:	83 c4 08             	add    $0x8,%esp
  iret
8010629f:	cf                   	iret   

801062a0 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801062a0:	55                   	push   %ebp
801062a1:	89 e5                	mov    %esp,%ebp
801062a3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801062a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801062a9:	83 e8 01             	sub    $0x1,%eax
801062ac:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801062b0:	8b 45 08             	mov    0x8(%ebp),%eax
801062b3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801062b7:	8b 45 08             	mov    0x8(%ebp),%eax
801062ba:	c1 e8 10             	shr    $0x10,%eax
801062bd:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801062c1:	8d 45 fa             	lea    -0x6(%ebp),%eax
801062c4:	0f 01 18             	lidtl  (%eax)
}
801062c7:	90                   	nop
801062c8:	c9                   	leave  
801062c9:	c3                   	ret    

801062ca <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801062ca:	55                   	push   %ebp
801062cb:	89 e5                	mov    %esp,%ebp
801062cd:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801062d0:	0f 20 d0             	mov    %cr2,%eax
801062d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801062d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801062d9:	c9                   	leave  
801062da:	c3                   	ret    

801062db <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801062db:	55                   	push   %ebp
801062dc:	89 e5                	mov    %esp,%ebp
801062de:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801062e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801062e8:	e9 c3 00 00 00       	jmp    801063b0 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801062ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f0:	8b 04 85 a8 b0 10 80 	mov    -0x7fef4f58(,%eax,4),%eax
801062f7:	89 c2                	mov    %eax,%edx
801062f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062fc:	66 89 14 c5 e0 1e 11 	mov    %dx,-0x7feee120(,%eax,8)
80106303:	80 
80106304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106307:	66 c7 04 c5 e2 1e 11 	movw   $0x8,-0x7feee11e(,%eax,8)
8010630e:	80 08 00 
80106311:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106314:	0f b6 14 c5 e4 1e 11 	movzbl -0x7feee11c(,%eax,8),%edx
8010631b:	80 
8010631c:	83 e2 e0             	and    $0xffffffe0,%edx
8010631f:	88 14 c5 e4 1e 11 80 	mov    %dl,-0x7feee11c(,%eax,8)
80106326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106329:	0f b6 14 c5 e4 1e 11 	movzbl -0x7feee11c(,%eax,8),%edx
80106330:	80 
80106331:	83 e2 1f             	and    $0x1f,%edx
80106334:	88 14 c5 e4 1e 11 80 	mov    %dl,-0x7feee11c(,%eax,8)
8010633b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633e:	0f b6 14 c5 e5 1e 11 	movzbl -0x7feee11b(,%eax,8),%edx
80106345:	80 
80106346:	83 e2 f0             	and    $0xfffffff0,%edx
80106349:	83 ca 0e             	or     $0xe,%edx
8010634c:	88 14 c5 e5 1e 11 80 	mov    %dl,-0x7feee11b(,%eax,8)
80106353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106356:	0f b6 14 c5 e5 1e 11 	movzbl -0x7feee11b(,%eax,8),%edx
8010635d:	80 
8010635e:	83 e2 ef             	and    $0xffffffef,%edx
80106361:	88 14 c5 e5 1e 11 80 	mov    %dl,-0x7feee11b(,%eax,8)
80106368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010636b:	0f b6 14 c5 e5 1e 11 	movzbl -0x7feee11b(,%eax,8),%edx
80106372:	80 
80106373:	83 e2 9f             	and    $0xffffff9f,%edx
80106376:	88 14 c5 e5 1e 11 80 	mov    %dl,-0x7feee11b(,%eax,8)
8010637d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106380:	0f b6 14 c5 e5 1e 11 	movzbl -0x7feee11b(,%eax,8),%edx
80106387:	80 
80106388:	83 ca 80             	or     $0xffffff80,%edx
8010638b:	88 14 c5 e5 1e 11 80 	mov    %dl,-0x7feee11b(,%eax,8)
80106392:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106395:	8b 04 85 a8 b0 10 80 	mov    -0x7fef4f58(,%eax,4),%eax
8010639c:	c1 e8 10             	shr    $0x10,%eax
8010639f:	89 c2                	mov    %eax,%edx
801063a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a4:	66 89 14 c5 e6 1e 11 	mov    %dx,-0x7feee11a(,%eax,8)
801063ab:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801063ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801063b0:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801063b7:	0f 8e 30 ff ff ff    	jle    801062ed <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801063bd:	a1 a8 b1 10 80       	mov    0x8010b1a8,%eax
801063c2:	66 a3 e0 20 11 80    	mov    %ax,0x801120e0
801063c8:	66 c7 05 e2 20 11 80 	movw   $0x8,0x801120e2
801063cf:	08 00 
801063d1:	0f b6 05 e4 20 11 80 	movzbl 0x801120e4,%eax
801063d8:	83 e0 e0             	and    $0xffffffe0,%eax
801063db:	a2 e4 20 11 80       	mov    %al,0x801120e4
801063e0:	0f b6 05 e4 20 11 80 	movzbl 0x801120e4,%eax
801063e7:	83 e0 1f             	and    $0x1f,%eax
801063ea:	a2 e4 20 11 80       	mov    %al,0x801120e4
801063ef:	0f b6 05 e5 20 11 80 	movzbl 0x801120e5,%eax
801063f6:	83 c8 0f             	or     $0xf,%eax
801063f9:	a2 e5 20 11 80       	mov    %al,0x801120e5
801063fe:	0f b6 05 e5 20 11 80 	movzbl 0x801120e5,%eax
80106405:	83 e0 ef             	and    $0xffffffef,%eax
80106408:	a2 e5 20 11 80       	mov    %al,0x801120e5
8010640d:	0f b6 05 e5 20 11 80 	movzbl 0x801120e5,%eax
80106414:	83 c8 60             	or     $0x60,%eax
80106417:	a2 e5 20 11 80       	mov    %al,0x801120e5
8010641c:	0f b6 05 e5 20 11 80 	movzbl 0x801120e5,%eax
80106423:	83 c8 80             	or     $0xffffff80,%eax
80106426:	a2 e5 20 11 80       	mov    %al,0x801120e5
8010642b:	a1 a8 b1 10 80       	mov    0x8010b1a8,%eax
80106430:	c1 e8 10             	shr    $0x10,%eax
80106433:	66 a3 e6 20 11 80    	mov    %ax,0x801120e6
  
  initlock(&tickslock, "time");
80106439:	83 ec 08             	sub    $0x8,%esp
8010643c:	68 d4 85 10 80       	push   $0x801085d4
80106441:	68 a0 1e 11 80       	push   $0x80111ea0
80106446:	e8 59 e7 ff ff       	call   80104ba4 <initlock>
8010644b:	83 c4 10             	add    $0x10,%esp
}
8010644e:	90                   	nop
8010644f:	c9                   	leave  
80106450:	c3                   	ret    

80106451 <idtinit>:

void
idtinit(void)
{
80106451:	55                   	push   %ebp
80106452:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106454:	68 00 08 00 00       	push   $0x800
80106459:	68 e0 1e 11 80       	push   $0x80111ee0
8010645e:	e8 3d fe ff ff       	call   801062a0 <lidt>
80106463:	83 c4 08             	add    $0x8,%esp
}
80106466:	90                   	nop
80106467:	c9                   	leave  
80106468:	c3                   	ret    

80106469 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106469:	55                   	push   %ebp
8010646a:	89 e5                	mov    %esp,%ebp
8010646c:	57                   	push   %edi
8010646d:	56                   	push   %esi
8010646e:	53                   	push   %ebx
8010646f:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106472:	8b 45 08             	mov    0x8(%ebp),%eax
80106475:	8b 40 30             	mov    0x30(%eax),%eax
80106478:	83 f8 40             	cmp    $0x40,%eax
8010647b:	75 3e                	jne    801064bb <trap+0x52>
    if(proc->killed)
8010647d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106483:	8b 40 24             	mov    0x24(%eax),%eax
80106486:	85 c0                	test   %eax,%eax
80106488:	74 05                	je     8010648f <trap+0x26>
      exit();
8010648a:	e8 1f e0 ff ff       	call   801044ae <exit>
    proc->tf = tf;
8010648f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106495:	8b 55 08             	mov    0x8(%ebp),%edx
80106498:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010649b:	e8 64 ed ff ff       	call   80105204 <syscall>
    if(proc->killed)
801064a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064a6:	8b 40 24             	mov    0x24(%eax),%eax
801064a9:	85 c0                	test   %eax,%eax
801064ab:	0f 84 1b 02 00 00    	je     801066cc <trap+0x263>
      exit();
801064b1:	e8 f8 df ff ff       	call   801044ae <exit>
    return;
801064b6:	e9 11 02 00 00       	jmp    801066cc <trap+0x263>
  }

  switch(tf->trapno){
801064bb:	8b 45 08             	mov    0x8(%ebp),%eax
801064be:	8b 40 30             	mov    0x30(%eax),%eax
801064c1:	83 e8 20             	sub    $0x20,%eax
801064c4:	83 f8 1f             	cmp    $0x1f,%eax
801064c7:	0f 87 c0 00 00 00    	ja     8010658d <trap+0x124>
801064cd:	8b 04 85 7c 86 10 80 	mov    -0x7fef7984(,%eax,4),%eax
801064d4:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801064d6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801064dc:	0f b6 00             	movzbl (%eax),%eax
801064df:	84 c0                	test   %al,%al
801064e1:	75 3d                	jne    80106520 <trap+0xb7>
      acquire(&tickslock);
801064e3:	83 ec 0c             	sub    $0xc,%esp
801064e6:	68 a0 1e 11 80       	push   $0x80111ea0
801064eb:	e8 d6 e6 ff ff       	call   80104bc6 <acquire>
801064f0:	83 c4 10             	add    $0x10,%esp
      ticks++;
801064f3:	a1 e0 26 11 80       	mov    0x801126e0,%eax
801064f8:	83 c0 01             	add    $0x1,%eax
801064fb:	a3 e0 26 11 80       	mov    %eax,0x801126e0
      wakeup(&ticks);
80106500:	83 ec 0c             	sub    $0xc,%esp
80106503:	68 e0 26 11 80       	push   $0x801126e0
80106508:	e8 ab e4 ff ff       	call   801049b8 <wakeup>
8010650d:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106510:	83 ec 0c             	sub    $0xc,%esp
80106513:	68 a0 1e 11 80       	push   $0x80111ea0
80106518:	e8 10 e7 ff ff       	call   80104c2d <release>
8010651d:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106520:	e8 2e ca ff ff       	call   80102f53 <lapiceoi>
    break;
80106525:	e9 1c 01 00 00       	jmp    80106646 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010652a:	e8 54 c2 ff ff       	call   80102783 <ideintr>
    lapiceoi();
8010652f:	e8 1f ca ff ff       	call   80102f53 <lapiceoi>
    break;
80106534:	e9 0d 01 00 00       	jmp    80106646 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106539:	e8 34 c8 ff ff       	call   80102d72 <kbdintr>
    lapiceoi();
8010653e:	e8 10 ca ff ff       	call   80102f53 <lapiceoi>
    break;
80106543:	e9 fe 00 00 00       	jmp    80106646 <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106548:	e8 60 03 00 00       	call   801068ad <uartintr>
    lapiceoi();
8010654d:	e8 01 ca ff ff       	call   80102f53 <lapiceoi>
    break;
80106552:	e9 ef 00 00 00       	jmp    80106646 <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106557:	8b 45 08             	mov    0x8(%ebp),%eax
8010655a:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
8010655d:	8b 45 08             	mov    0x8(%ebp),%eax
80106560:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106564:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106567:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010656d:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106570:	0f b6 c0             	movzbl %al,%eax
80106573:	51                   	push   %ecx
80106574:	52                   	push   %edx
80106575:	50                   	push   %eax
80106576:	68 dc 85 10 80       	push   $0x801085dc
8010657b:	e8 46 9e ff ff       	call   801003c6 <cprintf>
80106580:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106583:	e8 cb c9 ff ff       	call   80102f53 <lapiceoi>
    break;
80106588:	e9 b9 00 00 00       	jmp    80106646 <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010658d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106593:	85 c0                	test   %eax,%eax
80106595:	74 11                	je     801065a8 <trap+0x13f>
80106597:	8b 45 08             	mov    0x8(%ebp),%eax
8010659a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010659e:	0f b7 c0             	movzwl %ax,%eax
801065a1:	83 e0 03             	and    $0x3,%eax
801065a4:	85 c0                	test   %eax,%eax
801065a6:	75 40                	jne    801065e8 <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801065a8:	e8 1d fd ff ff       	call   801062ca <rcr2>
801065ad:	89 c3                	mov    %eax,%ebx
801065af:	8b 45 08             	mov    0x8(%ebp),%eax
801065b2:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801065b5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801065bb:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801065be:	0f b6 d0             	movzbl %al,%edx
801065c1:	8b 45 08             	mov    0x8(%ebp),%eax
801065c4:	8b 40 30             	mov    0x30(%eax),%eax
801065c7:	83 ec 0c             	sub    $0xc,%esp
801065ca:	53                   	push   %ebx
801065cb:	51                   	push   %ecx
801065cc:	52                   	push   %edx
801065cd:	50                   	push   %eax
801065ce:	68 00 86 10 80       	push   $0x80108600
801065d3:	e8 ee 9d ff ff       	call   801003c6 <cprintf>
801065d8:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801065db:	83 ec 0c             	sub    $0xc,%esp
801065de:	68 32 86 10 80       	push   $0x80108632
801065e3:	e8 7e 9f ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065e8:	e8 dd fc ff ff       	call   801062ca <rcr2>
801065ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801065f0:	8b 45 08             	mov    0x8(%ebp),%eax
801065f3:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801065f6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801065fc:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065ff:	0f b6 d8             	movzbl %al,%ebx
80106602:	8b 45 08             	mov    0x8(%ebp),%eax
80106605:	8b 48 34             	mov    0x34(%eax),%ecx
80106608:	8b 45 08             	mov    0x8(%ebp),%eax
8010660b:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010660e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106614:	8d 78 6c             	lea    0x6c(%eax),%edi
80106617:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010661d:	8b 40 10             	mov    0x10(%eax),%eax
80106620:	ff 75 e4             	pushl  -0x1c(%ebp)
80106623:	56                   	push   %esi
80106624:	53                   	push   %ebx
80106625:	51                   	push   %ecx
80106626:	52                   	push   %edx
80106627:	57                   	push   %edi
80106628:	50                   	push   %eax
80106629:	68 38 86 10 80       	push   $0x80108638
8010662e:	e8 93 9d ff ff       	call   801003c6 <cprintf>
80106633:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106636:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010663c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106643:	eb 01                	jmp    80106646 <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106645:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106646:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010664c:	85 c0                	test   %eax,%eax
8010664e:	74 24                	je     80106674 <trap+0x20b>
80106650:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106656:	8b 40 24             	mov    0x24(%eax),%eax
80106659:	85 c0                	test   %eax,%eax
8010665b:	74 17                	je     80106674 <trap+0x20b>
8010665d:	8b 45 08             	mov    0x8(%ebp),%eax
80106660:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106664:	0f b7 c0             	movzwl %ax,%eax
80106667:	83 e0 03             	and    $0x3,%eax
8010666a:	83 f8 03             	cmp    $0x3,%eax
8010666d:	75 05                	jne    80106674 <trap+0x20b>
    exit();
8010666f:	e8 3a de ff ff       	call   801044ae <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106674:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010667a:	85 c0                	test   %eax,%eax
8010667c:	74 1e                	je     8010669c <trap+0x233>
8010667e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106684:	8b 40 0c             	mov    0xc(%eax),%eax
80106687:	83 f8 04             	cmp    $0x4,%eax
8010668a:	75 10                	jne    8010669c <trap+0x233>
8010668c:	8b 45 08             	mov    0x8(%ebp),%eax
8010668f:	8b 40 30             	mov    0x30(%eax),%eax
80106692:	83 f8 20             	cmp    $0x20,%eax
80106695:	75 05                	jne    8010669c <trap+0x233>
    yield();
80106697:	e8 c5 e1 ff ff       	call   80104861 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010669c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066a2:	85 c0                	test   %eax,%eax
801066a4:	74 27                	je     801066cd <trap+0x264>
801066a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066ac:	8b 40 24             	mov    0x24(%eax),%eax
801066af:	85 c0                	test   %eax,%eax
801066b1:	74 1a                	je     801066cd <trap+0x264>
801066b3:	8b 45 08             	mov    0x8(%ebp),%eax
801066b6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066ba:	0f b7 c0             	movzwl %ax,%eax
801066bd:	83 e0 03             	and    $0x3,%eax
801066c0:	83 f8 03             	cmp    $0x3,%eax
801066c3:	75 08                	jne    801066cd <trap+0x264>
    exit();
801066c5:	e8 e4 dd ff ff       	call   801044ae <exit>
801066ca:	eb 01                	jmp    801066cd <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801066cc:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801066cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066d0:	5b                   	pop    %ebx
801066d1:	5e                   	pop    %esi
801066d2:	5f                   	pop    %edi
801066d3:	5d                   	pop    %ebp
801066d4:	c3                   	ret    

801066d5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801066d5:	55                   	push   %ebp
801066d6:	89 e5                	mov    %esp,%ebp
801066d8:	83 ec 14             	sub    $0x14,%esp
801066db:	8b 45 08             	mov    0x8(%ebp),%eax
801066de:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801066e2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801066e6:	89 c2                	mov    %eax,%edx
801066e8:	ec                   	in     (%dx),%al
801066e9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801066ec:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801066f0:	c9                   	leave  
801066f1:	c3                   	ret    

801066f2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801066f2:	55                   	push   %ebp
801066f3:	89 e5                	mov    %esp,%ebp
801066f5:	83 ec 08             	sub    $0x8,%esp
801066f8:	8b 55 08             	mov    0x8(%ebp),%edx
801066fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801066fe:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106702:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106705:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106709:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010670d:	ee                   	out    %al,(%dx)
}
8010670e:	90                   	nop
8010670f:	c9                   	leave  
80106710:	c3                   	ret    

80106711 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106711:	55                   	push   %ebp
80106712:	89 e5                	mov    %esp,%ebp
80106714:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106717:	6a 00                	push   $0x0
80106719:	68 fa 03 00 00       	push   $0x3fa
8010671e:	e8 cf ff ff ff       	call   801066f2 <outb>
80106723:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106726:	68 80 00 00 00       	push   $0x80
8010672b:	68 fb 03 00 00       	push   $0x3fb
80106730:	e8 bd ff ff ff       	call   801066f2 <outb>
80106735:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106738:	6a 0c                	push   $0xc
8010673a:	68 f8 03 00 00       	push   $0x3f8
8010673f:	e8 ae ff ff ff       	call   801066f2 <outb>
80106744:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106747:	6a 00                	push   $0x0
80106749:	68 f9 03 00 00       	push   $0x3f9
8010674e:	e8 9f ff ff ff       	call   801066f2 <outb>
80106753:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106756:	6a 03                	push   $0x3
80106758:	68 fb 03 00 00       	push   $0x3fb
8010675d:	e8 90 ff ff ff       	call   801066f2 <outb>
80106762:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106765:	6a 00                	push   $0x0
80106767:	68 fc 03 00 00       	push   $0x3fc
8010676c:	e8 81 ff ff ff       	call   801066f2 <outb>
80106771:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106774:	6a 01                	push   $0x1
80106776:	68 f9 03 00 00       	push   $0x3f9
8010677b:	e8 72 ff ff ff       	call   801066f2 <outb>
80106780:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106783:	68 fd 03 00 00       	push   $0x3fd
80106788:	e8 48 ff ff ff       	call   801066d5 <inb>
8010678d:	83 c4 04             	add    $0x4,%esp
80106790:	3c ff                	cmp    $0xff,%al
80106792:	74 6e                	je     80106802 <uartinit+0xf1>
    return;
  uart = 1;
80106794:	c7 05 6c b6 10 80 01 	movl   $0x1,0x8010b66c
8010679b:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010679e:	68 fa 03 00 00       	push   $0x3fa
801067a3:	e8 2d ff ff ff       	call   801066d5 <inb>
801067a8:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801067ab:	68 f8 03 00 00       	push   $0x3f8
801067b0:	e8 20 ff ff ff       	call   801066d5 <inb>
801067b5:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
801067b8:	83 ec 0c             	sub    $0xc,%esp
801067bb:	6a 04                	push   $0x4
801067bd:	e8 6f d3 ff ff       	call   80103b31 <picenable>
801067c2:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
801067c5:	83 ec 08             	sub    $0x8,%esp
801067c8:	6a 00                	push   $0x0
801067ca:	6a 04                	push   $0x4
801067cc:	e8 54 c2 ff ff       	call   80102a25 <ioapicenable>
801067d1:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801067d4:	c7 45 f4 fc 86 10 80 	movl   $0x801086fc,-0xc(%ebp)
801067db:	eb 19                	jmp    801067f6 <uartinit+0xe5>
    uartputc(*p);
801067dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e0:	0f b6 00             	movzbl (%eax),%eax
801067e3:	0f be c0             	movsbl %al,%eax
801067e6:	83 ec 0c             	sub    $0xc,%esp
801067e9:	50                   	push   %eax
801067ea:	e8 16 00 00 00       	call   80106805 <uartputc>
801067ef:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801067f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f9:	0f b6 00             	movzbl (%eax),%eax
801067fc:	84 c0                	test   %al,%al
801067fe:	75 dd                	jne    801067dd <uartinit+0xcc>
80106800:	eb 01                	jmp    80106803 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106802:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106803:	c9                   	leave  
80106804:	c3                   	ret    

80106805 <uartputc>:

void
uartputc(int c)
{
80106805:	55                   	push   %ebp
80106806:	89 e5                	mov    %esp,%ebp
80106808:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010680b:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106810:	85 c0                	test   %eax,%eax
80106812:	74 53                	je     80106867 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106814:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010681b:	eb 11                	jmp    8010682e <uartputc+0x29>
    microdelay(10);
8010681d:	83 ec 0c             	sub    $0xc,%esp
80106820:	6a 0a                	push   $0xa
80106822:	e8 47 c7 ff ff       	call   80102f6e <microdelay>
80106827:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010682a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010682e:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106832:	7f 1a                	jg     8010684e <uartputc+0x49>
80106834:	83 ec 0c             	sub    $0xc,%esp
80106837:	68 fd 03 00 00       	push   $0x3fd
8010683c:	e8 94 fe ff ff       	call   801066d5 <inb>
80106841:	83 c4 10             	add    $0x10,%esp
80106844:	0f b6 c0             	movzbl %al,%eax
80106847:	83 e0 20             	and    $0x20,%eax
8010684a:	85 c0                	test   %eax,%eax
8010684c:	74 cf                	je     8010681d <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
8010684e:	8b 45 08             	mov    0x8(%ebp),%eax
80106851:	0f b6 c0             	movzbl %al,%eax
80106854:	83 ec 08             	sub    $0x8,%esp
80106857:	50                   	push   %eax
80106858:	68 f8 03 00 00       	push   $0x3f8
8010685d:	e8 90 fe ff ff       	call   801066f2 <outb>
80106862:	83 c4 10             	add    $0x10,%esp
80106865:	eb 01                	jmp    80106868 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106867:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106868:	c9                   	leave  
80106869:	c3                   	ret    

8010686a <uartgetc>:

static int
uartgetc(void)
{
8010686a:	55                   	push   %ebp
8010686b:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010686d:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106872:	85 c0                	test   %eax,%eax
80106874:	75 07                	jne    8010687d <uartgetc+0x13>
    return -1;
80106876:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010687b:	eb 2e                	jmp    801068ab <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010687d:	68 fd 03 00 00       	push   $0x3fd
80106882:	e8 4e fe ff ff       	call   801066d5 <inb>
80106887:	83 c4 04             	add    $0x4,%esp
8010688a:	0f b6 c0             	movzbl %al,%eax
8010688d:	83 e0 01             	and    $0x1,%eax
80106890:	85 c0                	test   %eax,%eax
80106892:	75 07                	jne    8010689b <uartgetc+0x31>
    return -1;
80106894:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106899:	eb 10                	jmp    801068ab <uartgetc+0x41>
  return inb(COM1+0);
8010689b:	68 f8 03 00 00       	push   $0x3f8
801068a0:	e8 30 fe ff ff       	call   801066d5 <inb>
801068a5:	83 c4 04             	add    $0x4,%esp
801068a8:	0f b6 c0             	movzbl %al,%eax
}
801068ab:	c9                   	leave  
801068ac:	c3                   	ret    

801068ad <uartintr>:

void
uartintr(void)
{
801068ad:	55                   	push   %ebp
801068ae:	89 e5                	mov    %esp,%ebp
801068b0:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801068b3:	83 ec 0c             	sub    $0xc,%esp
801068b6:	68 6a 68 10 80       	push   $0x8010686a
801068bb:	e8 1d 9f ff ff       	call   801007dd <consoleintr>
801068c0:	83 c4 10             	add    $0x10,%esp
}
801068c3:	90                   	nop
801068c4:	c9                   	leave  
801068c5:	c3                   	ret    

801068c6 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801068c6:	6a 00                	push   $0x0
  pushl $0
801068c8:	6a 00                	push   $0x0
  jmp alltraps
801068ca:	e9 a6 f9 ff ff       	jmp    80106275 <alltraps>

801068cf <vector1>:
.globl vector1
vector1:
  pushl $0
801068cf:	6a 00                	push   $0x0
  pushl $1
801068d1:	6a 01                	push   $0x1
  jmp alltraps
801068d3:	e9 9d f9 ff ff       	jmp    80106275 <alltraps>

801068d8 <vector2>:
.globl vector2
vector2:
  pushl $0
801068d8:	6a 00                	push   $0x0
  pushl $2
801068da:	6a 02                	push   $0x2
  jmp alltraps
801068dc:	e9 94 f9 ff ff       	jmp    80106275 <alltraps>

801068e1 <vector3>:
.globl vector3
vector3:
  pushl $0
801068e1:	6a 00                	push   $0x0
  pushl $3
801068e3:	6a 03                	push   $0x3
  jmp alltraps
801068e5:	e9 8b f9 ff ff       	jmp    80106275 <alltraps>

801068ea <vector4>:
.globl vector4
vector4:
  pushl $0
801068ea:	6a 00                	push   $0x0
  pushl $4
801068ec:	6a 04                	push   $0x4
  jmp alltraps
801068ee:	e9 82 f9 ff ff       	jmp    80106275 <alltraps>

801068f3 <vector5>:
.globl vector5
vector5:
  pushl $0
801068f3:	6a 00                	push   $0x0
  pushl $5
801068f5:	6a 05                	push   $0x5
  jmp alltraps
801068f7:	e9 79 f9 ff ff       	jmp    80106275 <alltraps>

801068fc <vector6>:
.globl vector6
vector6:
  pushl $0
801068fc:	6a 00                	push   $0x0
  pushl $6
801068fe:	6a 06                	push   $0x6
  jmp alltraps
80106900:	e9 70 f9 ff ff       	jmp    80106275 <alltraps>

80106905 <vector7>:
.globl vector7
vector7:
  pushl $0
80106905:	6a 00                	push   $0x0
  pushl $7
80106907:	6a 07                	push   $0x7
  jmp alltraps
80106909:	e9 67 f9 ff ff       	jmp    80106275 <alltraps>

8010690e <vector8>:
.globl vector8
vector8:
  pushl $8
8010690e:	6a 08                	push   $0x8
  jmp alltraps
80106910:	e9 60 f9 ff ff       	jmp    80106275 <alltraps>

80106915 <vector9>:
.globl vector9
vector9:
  pushl $0
80106915:	6a 00                	push   $0x0
  pushl $9
80106917:	6a 09                	push   $0x9
  jmp alltraps
80106919:	e9 57 f9 ff ff       	jmp    80106275 <alltraps>

8010691e <vector10>:
.globl vector10
vector10:
  pushl $10
8010691e:	6a 0a                	push   $0xa
  jmp alltraps
80106920:	e9 50 f9 ff ff       	jmp    80106275 <alltraps>

80106925 <vector11>:
.globl vector11
vector11:
  pushl $11
80106925:	6a 0b                	push   $0xb
  jmp alltraps
80106927:	e9 49 f9 ff ff       	jmp    80106275 <alltraps>

8010692c <vector12>:
.globl vector12
vector12:
  pushl $12
8010692c:	6a 0c                	push   $0xc
  jmp alltraps
8010692e:	e9 42 f9 ff ff       	jmp    80106275 <alltraps>

80106933 <vector13>:
.globl vector13
vector13:
  pushl $13
80106933:	6a 0d                	push   $0xd
  jmp alltraps
80106935:	e9 3b f9 ff ff       	jmp    80106275 <alltraps>

8010693a <vector14>:
.globl vector14
vector14:
  pushl $14
8010693a:	6a 0e                	push   $0xe
  jmp alltraps
8010693c:	e9 34 f9 ff ff       	jmp    80106275 <alltraps>

80106941 <vector15>:
.globl vector15
vector15:
  pushl $0
80106941:	6a 00                	push   $0x0
  pushl $15
80106943:	6a 0f                	push   $0xf
  jmp alltraps
80106945:	e9 2b f9 ff ff       	jmp    80106275 <alltraps>

8010694a <vector16>:
.globl vector16
vector16:
  pushl $0
8010694a:	6a 00                	push   $0x0
  pushl $16
8010694c:	6a 10                	push   $0x10
  jmp alltraps
8010694e:	e9 22 f9 ff ff       	jmp    80106275 <alltraps>

80106953 <vector17>:
.globl vector17
vector17:
  pushl $17
80106953:	6a 11                	push   $0x11
  jmp alltraps
80106955:	e9 1b f9 ff ff       	jmp    80106275 <alltraps>

8010695a <vector18>:
.globl vector18
vector18:
  pushl $0
8010695a:	6a 00                	push   $0x0
  pushl $18
8010695c:	6a 12                	push   $0x12
  jmp alltraps
8010695e:	e9 12 f9 ff ff       	jmp    80106275 <alltraps>

80106963 <vector19>:
.globl vector19
vector19:
  pushl $0
80106963:	6a 00                	push   $0x0
  pushl $19
80106965:	6a 13                	push   $0x13
  jmp alltraps
80106967:	e9 09 f9 ff ff       	jmp    80106275 <alltraps>

8010696c <vector20>:
.globl vector20
vector20:
  pushl $0
8010696c:	6a 00                	push   $0x0
  pushl $20
8010696e:	6a 14                	push   $0x14
  jmp alltraps
80106970:	e9 00 f9 ff ff       	jmp    80106275 <alltraps>

80106975 <vector21>:
.globl vector21
vector21:
  pushl $0
80106975:	6a 00                	push   $0x0
  pushl $21
80106977:	6a 15                	push   $0x15
  jmp alltraps
80106979:	e9 f7 f8 ff ff       	jmp    80106275 <alltraps>

8010697e <vector22>:
.globl vector22
vector22:
  pushl $0
8010697e:	6a 00                	push   $0x0
  pushl $22
80106980:	6a 16                	push   $0x16
  jmp alltraps
80106982:	e9 ee f8 ff ff       	jmp    80106275 <alltraps>

80106987 <vector23>:
.globl vector23
vector23:
  pushl $0
80106987:	6a 00                	push   $0x0
  pushl $23
80106989:	6a 17                	push   $0x17
  jmp alltraps
8010698b:	e9 e5 f8 ff ff       	jmp    80106275 <alltraps>

80106990 <vector24>:
.globl vector24
vector24:
  pushl $0
80106990:	6a 00                	push   $0x0
  pushl $24
80106992:	6a 18                	push   $0x18
  jmp alltraps
80106994:	e9 dc f8 ff ff       	jmp    80106275 <alltraps>

80106999 <vector25>:
.globl vector25
vector25:
  pushl $0
80106999:	6a 00                	push   $0x0
  pushl $25
8010699b:	6a 19                	push   $0x19
  jmp alltraps
8010699d:	e9 d3 f8 ff ff       	jmp    80106275 <alltraps>

801069a2 <vector26>:
.globl vector26
vector26:
  pushl $0
801069a2:	6a 00                	push   $0x0
  pushl $26
801069a4:	6a 1a                	push   $0x1a
  jmp alltraps
801069a6:	e9 ca f8 ff ff       	jmp    80106275 <alltraps>

801069ab <vector27>:
.globl vector27
vector27:
  pushl $0
801069ab:	6a 00                	push   $0x0
  pushl $27
801069ad:	6a 1b                	push   $0x1b
  jmp alltraps
801069af:	e9 c1 f8 ff ff       	jmp    80106275 <alltraps>

801069b4 <vector28>:
.globl vector28
vector28:
  pushl $0
801069b4:	6a 00                	push   $0x0
  pushl $28
801069b6:	6a 1c                	push   $0x1c
  jmp alltraps
801069b8:	e9 b8 f8 ff ff       	jmp    80106275 <alltraps>

801069bd <vector29>:
.globl vector29
vector29:
  pushl $0
801069bd:	6a 00                	push   $0x0
  pushl $29
801069bf:	6a 1d                	push   $0x1d
  jmp alltraps
801069c1:	e9 af f8 ff ff       	jmp    80106275 <alltraps>

801069c6 <vector30>:
.globl vector30
vector30:
  pushl $0
801069c6:	6a 00                	push   $0x0
  pushl $30
801069c8:	6a 1e                	push   $0x1e
  jmp alltraps
801069ca:	e9 a6 f8 ff ff       	jmp    80106275 <alltraps>

801069cf <vector31>:
.globl vector31
vector31:
  pushl $0
801069cf:	6a 00                	push   $0x0
  pushl $31
801069d1:	6a 1f                	push   $0x1f
  jmp alltraps
801069d3:	e9 9d f8 ff ff       	jmp    80106275 <alltraps>

801069d8 <vector32>:
.globl vector32
vector32:
  pushl $0
801069d8:	6a 00                	push   $0x0
  pushl $32
801069da:	6a 20                	push   $0x20
  jmp alltraps
801069dc:	e9 94 f8 ff ff       	jmp    80106275 <alltraps>

801069e1 <vector33>:
.globl vector33
vector33:
  pushl $0
801069e1:	6a 00                	push   $0x0
  pushl $33
801069e3:	6a 21                	push   $0x21
  jmp alltraps
801069e5:	e9 8b f8 ff ff       	jmp    80106275 <alltraps>

801069ea <vector34>:
.globl vector34
vector34:
  pushl $0
801069ea:	6a 00                	push   $0x0
  pushl $34
801069ec:	6a 22                	push   $0x22
  jmp alltraps
801069ee:	e9 82 f8 ff ff       	jmp    80106275 <alltraps>

801069f3 <vector35>:
.globl vector35
vector35:
  pushl $0
801069f3:	6a 00                	push   $0x0
  pushl $35
801069f5:	6a 23                	push   $0x23
  jmp alltraps
801069f7:	e9 79 f8 ff ff       	jmp    80106275 <alltraps>

801069fc <vector36>:
.globl vector36
vector36:
  pushl $0
801069fc:	6a 00                	push   $0x0
  pushl $36
801069fe:	6a 24                	push   $0x24
  jmp alltraps
80106a00:	e9 70 f8 ff ff       	jmp    80106275 <alltraps>

80106a05 <vector37>:
.globl vector37
vector37:
  pushl $0
80106a05:	6a 00                	push   $0x0
  pushl $37
80106a07:	6a 25                	push   $0x25
  jmp alltraps
80106a09:	e9 67 f8 ff ff       	jmp    80106275 <alltraps>

80106a0e <vector38>:
.globl vector38
vector38:
  pushl $0
80106a0e:	6a 00                	push   $0x0
  pushl $38
80106a10:	6a 26                	push   $0x26
  jmp alltraps
80106a12:	e9 5e f8 ff ff       	jmp    80106275 <alltraps>

80106a17 <vector39>:
.globl vector39
vector39:
  pushl $0
80106a17:	6a 00                	push   $0x0
  pushl $39
80106a19:	6a 27                	push   $0x27
  jmp alltraps
80106a1b:	e9 55 f8 ff ff       	jmp    80106275 <alltraps>

80106a20 <vector40>:
.globl vector40
vector40:
  pushl $0
80106a20:	6a 00                	push   $0x0
  pushl $40
80106a22:	6a 28                	push   $0x28
  jmp alltraps
80106a24:	e9 4c f8 ff ff       	jmp    80106275 <alltraps>

80106a29 <vector41>:
.globl vector41
vector41:
  pushl $0
80106a29:	6a 00                	push   $0x0
  pushl $41
80106a2b:	6a 29                	push   $0x29
  jmp alltraps
80106a2d:	e9 43 f8 ff ff       	jmp    80106275 <alltraps>

80106a32 <vector42>:
.globl vector42
vector42:
  pushl $0
80106a32:	6a 00                	push   $0x0
  pushl $42
80106a34:	6a 2a                	push   $0x2a
  jmp alltraps
80106a36:	e9 3a f8 ff ff       	jmp    80106275 <alltraps>

80106a3b <vector43>:
.globl vector43
vector43:
  pushl $0
80106a3b:	6a 00                	push   $0x0
  pushl $43
80106a3d:	6a 2b                	push   $0x2b
  jmp alltraps
80106a3f:	e9 31 f8 ff ff       	jmp    80106275 <alltraps>

80106a44 <vector44>:
.globl vector44
vector44:
  pushl $0
80106a44:	6a 00                	push   $0x0
  pushl $44
80106a46:	6a 2c                	push   $0x2c
  jmp alltraps
80106a48:	e9 28 f8 ff ff       	jmp    80106275 <alltraps>

80106a4d <vector45>:
.globl vector45
vector45:
  pushl $0
80106a4d:	6a 00                	push   $0x0
  pushl $45
80106a4f:	6a 2d                	push   $0x2d
  jmp alltraps
80106a51:	e9 1f f8 ff ff       	jmp    80106275 <alltraps>

80106a56 <vector46>:
.globl vector46
vector46:
  pushl $0
80106a56:	6a 00                	push   $0x0
  pushl $46
80106a58:	6a 2e                	push   $0x2e
  jmp alltraps
80106a5a:	e9 16 f8 ff ff       	jmp    80106275 <alltraps>

80106a5f <vector47>:
.globl vector47
vector47:
  pushl $0
80106a5f:	6a 00                	push   $0x0
  pushl $47
80106a61:	6a 2f                	push   $0x2f
  jmp alltraps
80106a63:	e9 0d f8 ff ff       	jmp    80106275 <alltraps>

80106a68 <vector48>:
.globl vector48
vector48:
  pushl $0
80106a68:	6a 00                	push   $0x0
  pushl $48
80106a6a:	6a 30                	push   $0x30
  jmp alltraps
80106a6c:	e9 04 f8 ff ff       	jmp    80106275 <alltraps>

80106a71 <vector49>:
.globl vector49
vector49:
  pushl $0
80106a71:	6a 00                	push   $0x0
  pushl $49
80106a73:	6a 31                	push   $0x31
  jmp alltraps
80106a75:	e9 fb f7 ff ff       	jmp    80106275 <alltraps>

80106a7a <vector50>:
.globl vector50
vector50:
  pushl $0
80106a7a:	6a 00                	push   $0x0
  pushl $50
80106a7c:	6a 32                	push   $0x32
  jmp alltraps
80106a7e:	e9 f2 f7 ff ff       	jmp    80106275 <alltraps>

80106a83 <vector51>:
.globl vector51
vector51:
  pushl $0
80106a83:	6a 00                	push   $0x0
  pushl $51
80106a85:	6a 33                	push   $0x33
  jmp alltraps
80106a87:	e9 e9 f7 ff ff       	jmp    80106275 <alltraps>

80106a8c <vector52>:
.globl vector52
vector52:
  pushl $0
80106a8c:	6a 00                	push   $0x0
  pushl $52
80106a8e:	6a 34                	push   $0x34
  jmp alltraps
80106a90:	e9 e0 f7 ff ff       	jmp    80106275 <alltraps>

80106a95 <vector53>:
.globl vector53
vector53:
  pushl $0
80106a95:	6a 00                	push   $0x0
  pushl $53
80106a97:	6a 35                	push   $0x35
  jmp alltraps
80106a99:	e9 d7 f7 ff ff       	jmp    80106275 <alltraps>

80106a9e <vector54>:
.globl vector54
vector54:
  pushl $0
80106a9e:	6a 00                	push   $0x0
  pushl $54
80106aa0:	6a 36                	push   $0x36
  jmp alltraps
80106aa2:	e9 ce f7 ff ff       	jmp    80106275 <alltraps>

80106aa7 <vector55>:
.globl vector55
vector55:
  pushl $0
80106aa7:	6a 00                	push   $0x0
  pushl $55
80106aa9:	6a 37                	push   $0x37
  jmp alltraps
80106aab:	e9 c5 f7 ff ff       	jmp    80106275 <alltraps>

80106ab0 <vector56>:
.globl vector56
vector56:
  pushl $0
80106ab0:	6a 00                	push   $0x0
  pushl $56
80106ab2:	6a 38                	push   $0x38
  jmp alltraps
80106ab4:	e9 bc f7 ff ff       	jmp    80106275 <alltraps>

80106ab9 <vector57>:
.globl vector57
vector57:
  pushl $0
80106ab9:	6a 00                	push   $0x0
  pushl $57
80106abb:	6a 39                	push   $0x39
  jmp alltraps
80106abd:	e9 b3 f7 ff ff       	jmp    80106275 <alltraps>

80106ac2 <vector58>:
.globl vector58
vector58:
  pushl $0
80106ac2:	6a 00                	push   $0x0
  pushl $58
80106ac4:	6a 3a                	push   $0x3a
  jmp alltraps
80106ac6:	e9 aa f7 ff ff       	jmp    80106275 <alltraps>

80106acb <vector59>:
.globl vector59
vector59:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $59
80106acd:	6a 3b                	push   $0x3b
  jmp alltraps
80106acf:	e9 a1 f7 ff ff       	jmp    80106275 <alltraps>

80106ad4 <vector60>:
.globl vector60
vector60:
  pushl $0
80106ad4:	6a 00                	push   $0x0
  pushl $60
80106ad6:	6a 3c                	push   $0x3c
  jmp alltraps
80106ad8:	e9 98 f7 ff ff       	jmp    80106275 <alltraps>

80106add <vector61>:
.globl vector61
vector61:
  pushl $0
80106add:	6a 00                	push   $0x0
  pushl $61
80106adf:	6a 3d                	push   $0x3d
  jmp alltraps
80106ae1:	e9 8f f7 ff ff       	jmp    80106275 <alltraps>

80106ae6 <vector62>:
.globl vector62
vector62:
  pushl $0
80106ae6:	6a 00                	push   $0x0
  pushl $62
80106ae8:	6a 3e                	push   $0x3e
  jmp alltraps
80106aea:	e9 86 f7 ff ff       	jmp    80106275 <alltraps>

80106aef <vector63>:
.globl vector63
vector63:
  pushl $0
80106aef:	6a 00                	push   $0x0
  pushl $63
80106af1:	6a 3f                	push   $0x3f
  jmp alltraps
80106af3:	e9 7d f7 ff ff       	jmp    80106275 <alltraps>

80106af8 <vector64>:
.globl vector64
vector64:
  pushl $0
80106af8:	6a 00                	push   $0x0
  pushl $64
80106afa:	6a 40                	push   $0x40
  jmp alltraps
80106afc:	e9 74 f7 ff ff       	jmp    80106275 <alltraps>

80106b01 <vector65>:
.globl vector65
vector65:
  pushl $0
80106b01:	6a 00                	push   $0x0
  pushl $65
80106b03:	6a 41                	push   $0x41
  jmp alltraps
80106b05:	e9 6b f7 ff ff       	jmp    80106275 <alltraps>

80106b0a <vector66>:
.globl vector66
vector66:
  pushl $0
80106b0a:	6a 00                	push   $0x0
  pushl $66
80106b0c:	6a 42                	push   $0x42
  jmp alltraps
80106b0e:	e9 62 f7 ff ff       	jmp    80106275 <alltraps>

80106b13 <vector67>:
.globl vector67
vector67:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $67
80106b15:	6a 43                	push   $0x43
  jmp alltraps
80106b17:	e9 59 f7 ff ff       	jmp    80106275 <alltraps>

80106b1c <vector68>:
.globl vector68
vector68:
  pushl $0
80106b1c:	6a 00                	push   $0x0
  pushl $68
80106b1e:	6a 44                	push   $0x44
  jmp alltraps
80106b20:	e9 50 f7 ff ff       	jmp    80106275 <alltraps>

80106b25 <vector69>:
.globl vector69
vector69:
  pushl $0
80106b25:	6a 00                	push   $0x0
  pushl $69
80106b27:	6a 45                	push   $0x45
  jmp alltraps
80106b29:	e9 47 f7 ff ff       	jmp    80106275 <alltraps>

80106b2e <vector70>:
.globl vector70
vector70:
  pushl $0
80106b2e:	6a 00                	push   $0x0
  pushl $70
80106b30:	6a 46                	push   $0x46
  jmp alltraps
80106b32:	e9 3e f7 ff ff       	jmp    80106275 <alltraps>

80106b37 <vector71>:
.globl vector71
vector71:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $71
80106b39:	6a 47                	push   $0x47
  jmp alltraps
80106b3b:	e9 35 f7 ff ff       	jmp    80106275 <alltraps>

80106b40 <vector72>:
.globl vector72
vector72:
  pushl $0
80106b40:	6a 00                	push   $0x0
  pushl $72
80106b42:	6a 48                	push   $0x48
  jmp alltraps
80106b44:	e9 2c f7 ff ff       	jmp    80106275 <alltraps>

80106b49 <vector73>:
.globl vector73
vector73:
  pushl $0
80106b49:	6a 00                	push   $0x0
  pushl $73
80106b4b:	6a 49                	push   $0x49
  jmp alltraps
80106b4d:	e9 23 f7 ff ff       	jmp    80106275 <alltraps>

80106b52 <vector74>:
.globl vector74
vector74:
  pushl $0
80106b52:	6a 00                	push   $0x0
  pushl $74
80106b54:	6a 4a                	push   $0x4a
  jmp alltraps
80106b56:	e9 1a f7 ff ff       	jmp    80106275 <alltraps>

80106b5b <vector75>:
.globl vector75
vector75:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $75
80106b5d:	6a 4b                	push   $0x4b
  jmp alltraps
80106b5f:	e9 11 f7 ff ff       	jmp    80106275 <alltraps>

80106b64 <vector76>:
.globl vector76
vector76:
  pushl $0
80106b64:	6a 00                	push   $0x0
  pushl $76
80106b66:	6a 4c                	push   $0x4c
  jmp alltraps
80106b68:	e9 08 f7 ff ff       	jmp    80106275 <alltraps>

80106b6d <vector77>:
.globl vector77
vector77:
  pushl $0
80106b6d:	6a 00                	push   $0x0
  pushl $77
80106b6f:	6a 4d                	push   $0x4d
  jmp alltraps
80106b71:	e9 ff f6 ff ff       	jmp    80106275 <alltraps>

80106b76 <vector78>:
.globl vector78
vector78:
  pushl $0
80106b76:	6a 00                	push   $0x0
  pushl $78
80106b78:	6a 4e                	push   $0x4e
  jmp alltraps
80106b7a:	e9 f6 f6 ff ff       	jmp    80106275 <alltraps>

80106b7f <vector79>:
.globl vector79
vector79:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $79
80106b81:	6a 4f                	push   $0x4f
  jmp alltraps
80106b83:	e9 ed f6 ff ff       	jmp    80106275 <alltraps>

80106b88 <vector80>:
.globl vector80
vector80:
  pushl $0
80106b88:	6a 00                	push   $0x0
  pushl $80
80106b8a:	6a 50                	push   $0x50
  jmp alltraps
80106b8c:	e9 e4 f6 ff ff       	jmp    80106275 <alltraps>

80106b91 <vector81>:
.globl vector81
vector81:
  pushl $0
80106b91:	6a 00                	push   $0x0
  pushl $81
80106b93:	6a 51                	push   $0x51
  jmp alltraps
80106b95:	e9 db f6 ff ff       	jmp    80106275 <alltraps>

80106b9a <vector82>:
.globl vector82
vector82:
  pushl $0
80106b9a:	6a 00                	push   $0x0
  pushl $82
80106b9c:	6a 52                	push   $0x52
  jmp alltraps
80106b9e:	e9 d2 f6 ff ff       	jmp    80106275 <alltraps>

80106ba3 <vector83>:
.globl vector83
vector83:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $83
80106ba5:	6a 53                	push   $0x53
  jmp alltraps
80106ba7:	e9 c9 f6 ff ff       	jmp    80106275 <alltraps>

80106bac <vector84>:
.globl vector84
vector84:
  pushl $0
80106bac:	6a 00                	push   $0x0
  pushl $84
80106bae:	6a 54                	push   $0x54
  jmp alltraps
80106bb0:	e9 c0 f6 ff ff       	jmp    80106275 <alltraps>

80106bb5 <vector85>:
.globl vector85
vector85:
  pushl $0
80106bb5:	6a 00                	push   $0x0
  pushl $85
80106bb7:	6a 55                	push   $0x55
  jmp alltraps
80106bb9:	e9 b7 f6 ff ff       	jmp    80106275 <alltraps>

80106bbe <vector86>:
.globl vector86
vector86:
  pushl $0
80106bbe:	6a 00                	push   $0x0
  pushl $86
80106bc0:	6a 56                	push   $0x56
  jmp alltraps
80106bc2:	e9 ae f6 ff ff       	jmp    80106275 <alltraps>

80106bc7 <vector87>:
.globl vector87
vector87:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $87
80106bc9:	6a 57                	push   $0x57
  jmp alltraps
80106bcb:	e9 a5 f6 ff ff       	jmp    80106275 <alltraps>

80106bd0 <vector88>:
.globl vector88
vector88:
  pushl $0
80106bd0:	6a 00                	push   $0x0
  pushl $88
80106bd2:	6a 58                	push   $0x58
  jmp alltraps
80106bd4:	e9 9c f6 ff ff       	jmp    80106275 <alltraps>

80106bd9 <vector89>:
.globl vector89
vector89:
  pushl $0
80106bd9:	6a 00                	push   $0x0
  pushl $89
80106bdb:	6a 59                	push   $0x59
  jmp alltraps
80106bdd:	e9 93 f6 ff ff       	jmp    80106275 <alltraps>

80106be2 <vector90>:
.globl vector90
vector90:
  pushl $0
80106be2:	6a 00                	push   $0x0
  pushl $90
80106be4:	6a 5a                	push   $0x5a
  jmp alltraps
80106be6:	e9 8a f6 ff ff       	jmp    80106275 <alltraps>

80106beb <vector91>:
.globl vector91
vector91:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $91
80106bed:	6a 5b                	push   $0x5b
  jmp alltraps
80106bef:	e9 81 f6 ff ff       	jmp    80106275 <alltraps>

80106bf4 <vector92>:
.globl vector92
vector92:
  pushl $0
80106bf4:	6a 00                	push   $0x0
  pushl $92
80106bf6:	6a 5c                	push   $0x5c
  jmp alltraps
80106bf8:	e9 78 f6 ff ff       	jmp    80106275 <alltraps>

80106bfd <vector93>:
.globl vector93
vector93:
  pushl $0
80106bfd:	6a 00                	push   $0x0
  pushl $93
80106bff:	6a 5d                	push   $0x5d
  jmp alltraps
80106c01:	e9 6f f6 ff ff       	jmp    80106275 <alltraps>

80106c06 <vector94>:
.globl vector94
vector94:
  pushl $0
80106c06:	6a 00                	push   $0x0
  pushl $94
80106c08:	6a 5e                	push   $0x5e
  jmp alltraps
80106c0a:	e9 66 f6 ff ff       	jmp    80106275 <alltraps>

80106c0f <vector95>:
.globl vector95
vector95:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $95
80106c11:	6a 5f                	push   $0x5f
  jmp alltraps
80106c13:	e9 5d f6 ff ff       	jmp    80106275 <alltraps>

80106c18 <vector96>:
.globl vector96
vector96:
  pushl $0
80106c18:	6a 00                	push   $0x0
  pushl $96
80106c1a:	6a 60                	push   $0x60
  jmp alltraps
80106c1c:	e9 54 f6 ff ff       	jmp    80106275 <alltraps>

80106c21 <vector97>:
.globl vector97
vector97:
  pushl $0
80106c21:	6a 00                	push   $0x0
  pushl $97
80106c23:	6a 61                	push   $0x61
  jmp alltraps
80106c25:	e9 4b f6 ff ff       	jmp    80106275 <alltraps>

80106c2a <vector98>:
.globl vector98
vector98:
  pushl $0
80106c2a:	6a 00                	push   $0x0
  pushl $98
80106c2c:	6a 62                	push   $0x62
  jmp alltraps
80106c2e:	e9 42 f6 ff ff       	jmp    80106275 <alltraps>

80106c33 <vector99>:
.globl vector99
vector99:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $99
80106c35:	6a 63                	push   $0x63
  jmp alltraps
80106c37:	e9 39 f6 ff ff       	jmp    80106275 <alltraps>

80106c3c <vector100>:
.globl vector100
vector100:
  pushl $0
80106c3c:	6a 00                	push   $0x0
  pushl $100
80106c3e:	6a 64                	push   $0x64
  jmp alltraps
80106c40:	e9 30 f6 ff ff       	jmp    80106275 <alltraps>

80106c45 <vector101>:
.globl vector101
vector101:
  pushl $0
80106c45:	6a 00                	push   $0x0
  pushl $101
80106c47:	6a 65                	push   $0x65
  jmp alltraps
80106c49:	e9 27 f6 ff ff       	jmp    80106275 <alltraps>

80106c4e <vector102>:
.globl vector102
vector102:
  pushl $0
80106c4e:	6a 00                	push   $0x0
  pushl $102
80106c50:	6a 66                	push   $0x66
  jmp alltraps
80106c52:	e9 1e f6 ff ff       	jmp    80106275 <alltraps>

80106c57 <vector103>:
.globl vector103
vector103:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $103
80106c59:	6a 67                	push   $0x67
  jmp alltraps
80106c5b:	e9 15 f6 ff ff       	jmp    80106275 <alltraps>

80106c60 <vector104>:
.globl vector104
vector104:
  pushl $0
80106c60:	6a 00                	push   $0x0
  pushl $104
80106c62:	6a 68                	push   $0x68
  jmp alltraps
80106c64:	e9 0c f6 ff ff       	jmp    80106275 <alltraps>

80106c69 <vector105>:
.globl vector105
vector105:
  pushl $0
80106c69:	6a 00                	push   $0x0
  pushl $105
80106c6b:	6a 69                	push   $0x69
  jmp alltraps
80106c6d:	e9 03 f6 ff ff       	jmp    80106275 <alltraps>

80106c72 <vector106>:
.globl vector106
vector106:
  pushl $0
80106c72:	6a 00                	push   $0x0
  pushl $106
80106c74:	6a 6a                	push   $0x6a
  jmp alltraps
80106c76:	e9 fa f5 ff ff       	jmp    80106275 <alltraps>

80106c7b <vector107>:
.globl vector107
vector107:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $107
80106c7d:	6a 6b                	push   $0x6b
  jmp alltraps
80106c7f:	e9 f1 f5 ff ff       	jmp    80106275 <alltraps>

80106c84 <vector108>:
.globl vector108
vector108:
  pushl $0
80106c84:	6a 00                	push   $0x0
  pushl $108
80106c86:	6a 6c                	push   $0x6c
  jmp alltraps
80106c88:	e9 e8 f5 ff ff       	jmp    80106275 <alltraps>

80106c8d <vector109>:
.globl vector109
vector109:
  pushl $0
80106c8d:	6a 00                	push   $0x0
  pushl $109
80106c8f:	6a 6d                	push   $0x6d
  jmp alltraps
80106c91:	e9 df f5 ff ff       	jmp    80106275 <alltraps>

80106c96 <vector110>:
.globl vector110
vector110:
  pushl $0
80106c96:	6a 00                	push   $0x0
  pushl $110
80106c98:	6a 6e                	push   $0x6e
  jmp alltraps
80106c9a:	e9 d6 f5 ff ff       	jmp    80106275 <alltraps>

80106c9f <vector111>:
.globl vector111
vector111:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $111
80106ca1:	6a 6f                	push   $0x6f
  jmp alltraps
80106ca3:	e9 cd f5 ff ff       	jmp    80106275 <alltraps>

80106ca8 <vector112>:
.globl vector112
vector112:
  pushl $0
80106ca8:	6a 00                	push   $0x0
  pushl $112
80106caa:	6a 70                	push   $0x70
  jmp alltraps
80106cac:	e9 c4 f5 ff ff       	jmp    80106275 <alltraps>

80106cb1 <vector113>:
.globl vector113
vector113:
  pushl $0
80106cb1:	6a 00                	push   $0x0
  pushl $113
80106cb3:	6a 71                	push   $0x71
  jmp alltraps
80106cb5:	e9 bb f5 ff ff       	jmp    80106275 <alltraps>

80106cba <vector114>:
.globl vector114
vector114:
  pushl $0
80106cba:	6a 00                	push   $0x0
  pushl $114
80106cbc:	6a 72                	push   $0x72
  jmp alltraps
80106cbe:	e9 b2 f5 ff ff       	jmp    80106275 <alltraps>

80106cc3 <vector115>:
.globl vector115
vector115:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $115
80106cc5:	6a 73                	push   $0x73
  jmp alltraps
80106cc7:	e9 a9 f5 ff ff       	jmp    80106275 <alltraps>

80106ccc <vector116>:
.globl vector116
vector116:
  pushl $0
80106ccc:	6a 00                	push   $0x0
  pushl $116
80106cce:	6a 74                	push   $0x74
  jmp alltraps
80106cd0:	e9 a0 f5 ff ff       	jmp    80106275 <alltraps>

80106cd5 <vector117>:
.globl vector117
vector117:
  pushl $0
80106cd5:	6a 00                	push   $0x0
  pushl $117
80106cd7:	6a 75                	push   $0x75
  jmp alltraps
80106cd9:	e9 97 f5 ff ff       	jmp    80106275 <alltraps>

80106cde <vector118>:
.globl vector118
vector118:
  pushl $0
80106cde:	6a 00                	push   $0x0
  pushl $118
80106ce0:	6a 76                	push   $0x76
  jmp alltraps
80106ce2:	e9 8e f5 ff ff       	jmp    80106275 <alltraps>

80106ce7 <vector119>:
.globl vector119
vector119:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $119
80106ce9:	6a 77                	push   $0x77
  jmp alltraps
80106ceb:	e9 85 f5 ff ff       	jmp    80106275 <alltraps>

80106cf0 <vector120>:
.globl vector120
vector120:
  pushl $0
80106cf0:	6a 00                	push   $0x0
  pushl $120
80106cf2:	6a 78                	push   $0x78
  jmp alltraps
80106cf4:	e9 7c f5 ff ff       	jmp    80106275 <alltraps>

80106cf9 <vector121>:
.globl vector121
vector121:
  pushl $0
80106cf9:	6a 00                	push   $0x0
  pushl $121
80106cfb:	6a 79                	push   $0x79
  jmp alltraps
80106cfd:	e9 73 f5 ff ff       	jmp    80106275 <alltraps>

80106d02 <vector122>:
.globl vector122
vector122:
  pushl $0
80106d02:	6a 00                	push   $0x0
  pushl $122
80106d04:	6a 7a                	push   $0x7a
  jmp alltraps
80106d06:	e9 6a f5 ff ff       	jmp    80106275 <alltraps>

80106d0b <vector123>:
.globl vector123
vector123:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $123
80106d0d:	6a 7b                	push   $0x7b
  jmp alltraps
80106d0f:	e9 61 f5 ff ff       	jmp    80106275 <alltraps>

80106d14 <vector124>:
.globl vector124
vector124:
  pushl $0
80106d14:	6a 00                	push   $0x0
  pushl $124
80106d16:	6a 7c                	push   $0x7c
  jmp alltraps
80106d18:	e9 58 f5 ff ff       	jmp    80106275 <alltraps>

80106d1d <vector125>:
.globl vector125
vector125:
  pushl $0
80106d1d:	6a 00                	push   $0x0
  pushl $125
80106d1f:	6a 7d                	push   $0x7d
  jmp alltraps
80106d21:	e9 4f f5 ff ff       	jmp    80106275 <alltraps>

80106d26 <vector126>:
.globl vector126
vector126:
  pushl $0
80106d26:	6a 00                	push   $0x0
  pushl $126
80106d28:	6a 7e                	push   $0x7e
  jmp alltraps
80106d2a:	e9 46 f5 ff ff       	jmp    80106275 <alltraps>

80106d2f <vector127>:
.globl vector127
vector127:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $127
80106d31:	6a 7f                	push   $0x7f
  jmp alltraps
80106d33:	e9 3d f5 ff ff       	jmp    80106275 <alltraps>

80106d38 <vector128>:
.globl vector128
vector128:
  pushl $0
80106d38:	6a 00                	push   $0x0
  pushl $128
80106d3a:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106d3f:	e9 31 f5 ff ff       	jmp    80106275 <alltraps>

80106d44 <vector129>:
.globl vector129
vector129:
  pushl $0
80106d44:	6a 00                	push   $0x0
  pushl $129
80106d46:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106d4b:	e9 25 f5 ff ff       	jmp    80106275 <alltraps>

80106d50 <vector130>:
.globl vector130
vector130:
  pushl $0
80106d50:	6a 00                	push   $0x0
  pushl $130
80106d52:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106d57:	e9 19 f5 ff ff       	jmp    80106275 <alltraps>

80106d5c <vector131>:
.globl vector131
vector131:
  pushl $0
80106d5c:	6a 00                	push   $0x0
  pushl $131
80106d5e:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106d63:	e9 0d f5 ff ff       	jmp    80106275 <alltraps>

80106d68 <vector132>:
.globl vector132
vector132:
  pushl $0
80106d68:	6a 00                	push   $0x0
  pushl $132
80106d6a:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106d6f:	e9 01 f5 ff ff       	jmp    80106275 <alltraps>

80106d74 <vector133>:
.globl vector133
vector133:
  pushl $0
80106d74:	6a 00                	push   $0x0
  pushl $133
80106d76:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106d7b:	e9 f5 f4 ff ff       	jmp    80106275 <alltraps>

80106d80 <vector134>:
.globl vector134
vector134:
  pushl $0
80106d80:	6a 00                	push   $0x0
  pushl $134
80106d82:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106d87:	e9 e9 f4 ff ff       	jmp    80106275 <alltraps>

80106d8c <vector135>:
.globl vector135
vector135:
  pushl $0
80106d8c:	6a 00                	push   $0x0
  pushl $135
80106d8e:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106d93:	e9 dd f4 ff ff       	jmp    80106275 <alltraps>

80106d98 <vector136>:
.globl vector136
vector136:
  pushl $0
80106d98:	6a 00                	push   $0x0
  pushl $136
80106d9a:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106d9f:	e9 d1 f4 ff ff       	jmp    80106275 <alltraps>

80106da4 <vector137>:
.globl vector137
vector137:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $137
80106da6:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106dab:	e9 c5 f4 ff ff       	jmp    80106275 <alltraps>

80106db0 <vector138>:
.globl vector138
vector138:
  pushl $0
80106db0:	6a 00                	push   $0x0
  pushl $138
80106db2:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106db7:	e9 b9 f4 ff ff       	jmp    80106275 <alltraps>

80106dbc <vector139>:
.globl vector139
vector139:
  pushl $0
80106dbc:	6a 00                	push   $0x0
  pushl $139
80106dbe:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106dc3:	e9 ad f4 ff ff       	jmp    80106275 <alltraps>

80106dc8 <vector140>:
.globl vector140
vector140:
  pushl $0
80106dc8:	6a 00                	push   $0x0
  pushl $140
80106dca:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106dcf:	e9 a1 f4 ff ff       	jmp    80106275 <alltraps>

80106dd4 <vector141>:
.globl vector141
vector141:
  pushl $0
80106dd4:	6a 00                	push   $0x0
  pushl $141
80106dd6:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106ddb:	e9 95 f4 ff ff       	jmp    80106275 <alltraps>

80106de0 <vector142>:
.globl vector142
vector142:
  pushl $0
80106de0:	6a 00                	push   $0x0
  pushl $142
80106de2:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106de7:	e9 89 f4 ff ff       	jmp    80106275 <alltraps>

80106dec <vector143>:
.globl vector143
vector143:
  pushl $0
80106dec:	6a 00                	push   $0x0
  pushl $143
80106dee:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106df3:	e9 7d f4 ff ff       	jmp    80106275 <alltraps>

80106df8 <vector144>:
.globl vector144
vector144:
  pushl $0
80106df8:	6a 00                	push   $0x0
  pushl $144
80106dfa:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106dff:	e9 71 f4 ff ff       	jmp    80106275 <alltraps>

80106e04 <vector145>:
.globl vector145
vector145:
  pushl $0
80106e04:	6a 00                	push   $0x0
  pushl $145
80106e06:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106e0b:	e9 65 f4 ff ff       	jmp    80106275 <alltraps>

80106e10 <vector146>:
.globl vector146
vector146:
  pushl $0
80106e10:	6a 00                	push   $0x0
  pushl $146
80106e12:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106e17:	e9 59 f4 ff ff       	jmp    80106275 <alltraps>

80106e1c <vector147>:
.globl vector147
vector147:
  pushl $0
80106e1c:	6a 00                	push   $0x0
  pushl $147
80106e1e:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106e23:	e9 4d f4 ff ff       	jmp    80106275 <alltraps>

80106e28 <vector148>:
.globl vector148
vector148:
  pushl $0
80106e28:	6a 00                	push   $0x0
  pushl $148
80106e2a:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106e2f:	e9 41 f4 ff ff       	jmp    80106275 <alltraps>

80106e34 <vector149>:
.globl vector149
vector149:
  pushl $0
80106e34:	6a 00                	push   $0x0
  pushl $149
80106e36:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106e3b:	e9 35 f4 ff ff       	jmp    80106275 <alltraps>

80106e40 <vector150>:
.globl vector150
vector150:
  pushl $0
80106e40:	6a 00                	push   $0x0
  pushl $150
80106e42:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106e47:	e9 29 f4 ff ff       	jmp    80106275 <alltraps>

80106e4c <vector151>:
.globl vector151
vector151:
  pushl $0
80106e4c:	6a 00                	push   $0x0
  pushl $151
80106e4e:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106e53:	e9 1d f4 ff ff       	jmp    80106275 <alltraps>

80106e58 <vector152>:
.globl vector152
vector152:
  pushl $0
80106e58:	6a 00                	push   $0x0
  pushl $152
80106e5a:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106e5f:	e9 11 f4 ff ff       	jmp    80106275 <alltraps>

80106e64 <vector153>:
.globl vector153
vector153:
  pushl $0
80106e64:	6a 00                	push   $0x0
  pushl $153
80106e66:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106e6b:	e9 05 f4 ff ff       	jmp    80106275 <alltraps>

80106e70 <vector154>:
.globl vector154
vector154:
  pushl $0
80106e70:	6a 00                	push   $0x0
  pushl $154
80106e72:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106e77:	e9 f9 f3 ff ff       	jmp    80106275 <alltraps>

80106e7c <vector155>:
.globl vector155
vector155:
  pushl $0
80106e7c:	6a 00                	push   $0x0
  pushl $155
80106e7e:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106e83:	e9 ed f3 ff ff       	jmp    80106275 <alltraps>

80106e88 <vector156>:
.globl vector156
vector156:
  pushl $0
80106e88:	6a 00                	push   $0x0
  pushl $156
80106e8a:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106e8f:	e9 e1 f3 ff ff       	jmp    80106275 <alltraps>

80106e94 <vector157>:
.globl vector157
vector157:
  pushl $0
80106e94:	6a 00                	push   $0x0
  pushl $157
80106e96:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106e9b:	e9 d5 f3 ff ff       	jmp    80106275 <alltraps>

80106ea0 <vector158>:
.globl vector158
vector158:
  pushl $0
80106ea0:	6a 00                	push   $0x0
  pushl $158
80106ea2:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106ea7:	e9 c9 f3 ff ff       	jmp    80106275 <alltraps>

80106eac <vector159>:
.globl vector159
vector159:
  pushl $0
80106eac:	6a 00                	push   $0x0
  pushl $159
80106eae:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106eb3:	e9 bd f3 ff ff       	jmp    80106275 <alltraps>

80106eb8 <vector160>:
.globl vector160
vector160:
  pushl $0
80106eb8:	6a 00                	push   $0x0
  pushl $160
80106eba:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106ebf:	e9 b1 f3 ff ff       	jmp    80106275 <alltraps>

80106ec4 <vector161>:
.globl vector161
vector161:
  pushl $0
80106ec4:	6a 00                	push   $0x0
  pushl $161
80106ec6:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106ecb:	e9 a5 f3 ff ff       	jmp    80106275 <alltraps>

80106ed0 <vector162>:
.globl vector162
vector162:
  pushl $0
80106ed0:	6a 00                	push   $0x0
  pushl $162
80106ed2:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106ed7:	e9 99 f3 ff ff       	jmp    80106275 <alltraps>

80106edc <vector163>:
.globl vector163
vector163:
  pushl $0
80106edc:	6a 00                	push   $0x0
  pushl $163
80106ede:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106ee3:	e9 8d f3 ff ff       	jmp    80106275 <alltraps>

80106ee8 <vector164>:
.globl vector164
vector164:
  pushl $0
80106ee8:	6a 00                	push   $0x0
  pushl $164
80106eea:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106eef:	e9 81 f3 ff ff       	jmp    80106275 <alltraps>

80106ef4 <vector165>:
.globl vector165
vector165:
  pushl $0
80106ef4:	6a 00                	push   $0x0
  pushl $165
80106ef6:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106efb:	e9 75 f3 ff ff       	jmp    80106275 <alltraps>

80106f00 <vector166>:
.globl vector166
vector166:
  pushl $0
80106f00:	6a 00                	push   $0x0
  pushl $166
80106f02:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106f07:	e9 69 f3 ff ff       	jmp    80106275 <alltraps>

80106f0c <vector167>:
.globl vector167
vector167:
  pushl $0
80106f0c:	6a 00                	push   $0x0
  pushl $167
80106f0e:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106f13:	e9 5d f3 ff ff       	jmp    80106275 <alltraps>

80106f18 <vector168>:
.globl vector168
vector168:
  pushl $0
80106f18:	6a 00                	push   $0x0
  pushl $168
80106f1a:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106f1f:	e9 51 f3 ff ff       	jmp    80106275 <alltraps>

80106f24 <vector169>:
.globl vector169
vector169:
  pushl $0
80106f24:	6a 00                	push   $0x0
  pushl $169
80106f26:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106f2b:	e9 45 f3 ff ff       	jmp    80106275 <alltraps>

80106f30 <vector170>:
.globl vector170
vector170:
  pushl $0
80106f30:	6a 00                	push   $0x0
  pushl $170
80106f32:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106f37:	e9 39 f3 ff ff       	jmp    80106275 <alltraps>

80106f3c <vector171>:
.globl vector171
vector171:
  pushl $0
80106f3c:	6a 00                	push   $0x0
  pushl $171
80106f3e:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106f43:	e9 2d f3 ff ff       	jmp    80106275 <alltraps>

80106f48 <vector172>:
.globl vector172
vector172:
  pushl $0
80106f48:	6a 00                	push   $0x0
  pushl $172
80106f4a:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106f4f:	e9 21 f3 ff ff       	jmp    80106275 <alltraps>

80106f54 <vector173>:
.globl vector173
vector173:
  pushl $0
80106f54:	6a 00                	push   $0x0
  pushl $173
80106f56:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106f5b:	e9 15 f3 ff ff       	jmp    80106275 <alltraps>

80106f60 <vector174>:
.globl vector174
vector174:
  pushl $0
80106f60:	6a 00                	push   $0x0
  pushl $174
80106f62:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106f67:	e9 09 f3 ff ff       	jmp    80106275 <alltraps>

80106f6c <vector175>:
.globl vector175
vector175:
  pushl $0
80106f6c:	6a 00                	push   $0x0
  pushl $175
80106f6e:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106f73:	e9 fd f2 ff ff       	jmp    80106275 <alltraps>

80106f78 <vector176>:
.globl vector176
vector176:
  pushl $0
80106f78:	6a 00                	push   $0x0
  pushl $176
80106f7a:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106f7f:	e9 f1 f2 ff ff       	jmp    80106275 <alltraps>

80106f84 <vector177>:
.globl vector177
vector177:
  pushl $0
80106f84:	6a 00                	push   $0x0
  pushl $177
80106f86:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106f8b:	e9 e5 f2 ff ff       	jmp    80106275 <alltraps>

80106f90 <vector178>:
.globl vector178
vector178:
  pushl $0
80106f90:	6a 00                	push   $0x0
  pushl $178
80106f92:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106f97:	e9 d9 f2 ff ff       	jmp    80106275 <alltraps>

80106f9c <vector179>:
.globl vector179
vector179:
  pushl $0
80106f9c:	6a 00                	push   $0x0
  pushl $179
80106f9e:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106fa3:	e9 cd f2 ff ff       	jmp    80106275 <alltraps>

80106fa8 <vector180>:
.globl vector180
vector180:
  pushl $0
80106fa8:	6a 00                	push   $0x0
  pushl $180
80106faa:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106faf:	e9 c1 f2 ff ff       	jmp    80106275 <alltraps>

80106fb4 <vector181>:
.globl vector181
vector181:
  pushl $0
80106fb4:	6a 00                	push   $0x0
  pushl $181
80106fb6:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106fbb:	e9 b5 f2 ff ff       	jmp    80106275 <alltraps>

80106fc0 <vector182>:
.globl vector182
vector182:
  pushl $0
80106fc0:	6a 00                	push   $0x0
  pushl $182
80106fc2:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106fc7:	e9 a9 f2 ff ff       	jmp    80106275 <alltraps>

80106fcc <vector183>:
.globl vector183
vector183:
  pushl $0
80106fcc:	6a 00                	push   $0x0
  pushl $183
80106fce:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106fd3:	e9 9d f2 ff ff       	jmp    80106275 <alltraps>

80106fd8 <vector184>:
.globl vector184
vector184:
  pushl $0
80106fd8:	6a 00                	push   $0x0
  pushl $184
80106fda:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106fdf:	e9 91 f2 ff ff       	jmp    80106275 <alltraps>

80106fe4 <vector185>:
.globl vector185
vector185:
  pushl $0
80106fe4:	6a 00                	push   $0x0
  pushl $185
80106fe6:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106feb:	e9 85 f2 ff ff       	jmp    80106275 <alltraps>

80106ff0 <vector186>:
.globl vector186
vector186:
  pushl $0
80106ff0:	6a 00                	push   $0x0
  pushl $186
80106ff2:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106ff7:	e9 79 f2 ff ff       	jmp    80106275 <alltraps>

80106ffc <vector187>:
.globl vector187
vector187:
  pushl $0
80106ffc:	6a 00                	push   $0x0
  pushl $187
80106ffe:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107003:	e9 6d f2 ff ff       	jmp    80106275 <alltraps>

80107008 <vector188>:
.globl vector188
vector188:
  pushl $0
80107008:	6a 00                	push   $0x0
  pushl $188
8010700a:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010700f:	e9 61 f2 ff ff       	jmp    80106275 <alltraps>

80107014 <vector189>:
.globl vector189
vector189:
  pushl $0
80107014:	6a 00                	push   $0x0
  pushl $189
80107016:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010701b:	e9 55 f2 ff ff       	jmp    80106275 <alltraps>

80107020 <vector190>:
.globl vector190
vector190:
  pushl $0
80107020:	6a 00                	push   $0x0
  pushl $190
80107022:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107027:	e9 49 f2 ff ff       	jmp    80106275 <alltraps>

8010702c <vector191>:
.globl vector191
vector191:
  pushl $0
8010702c:	6a 00                	push   $0x0
  pushl $191
8010702e:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107033:	e9 3d f2 ff ff       	jmp    80106275 <alltraps>

80107038 <vector192>:
.globl vector192
vector192:
  pushl $0
80107038:	6a 00                	push   $0x0
  pushl $192
8010703a:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010703f:	e9 31 f2 ff ff       	jmp    80106275 <alltraps>

80107044 <vector193>:
.globl vector193
vector193:
  pushl $0
80107044:	6a 00                	push   $0x0
  pushl $193
80107046:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010704b:	e9 25 f2 ff ff       	jmp    80106275 <alltraps>

80107050 <vector194>:
.globl vector194
vector194:
  pushl $0
80107050:	6a 00                	push   $0x0
  pushl $194
80107052:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107057:	e9 19 f2 ff ff       	jmp    80106275 <alltraps>

8010705c <vector195>:
.globl vector195
vector195:
  pushl $0
8010705c:	6a 00                	push   $0x0
  pushl $195
8010705e:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107063:	e9 0d f2 ff ff       	jmp    80106275 <alltraps>

80107068 <vector196>:
.globl vector196
vector196:
  pushl $0
80107068:	6a 00                	push   $0x0
  pushl $196
8010706a:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010706f:	e9 01 f2 ff ff       	jmp    80106275 <alltraps>

80107074 <vector197>:
.globl vector197
vector197:
  pushl $0
80107074:	6a 00                	push   $0x0
  pushl $197
80107076:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010707b:	e9 f5 f1 ff ff       	jmp    80106275 <alltraps>

80107080 <vector198>:
.globl vector198
vector198:
  pushl $0
80107080:	6a 00                	push   $0x0
  pushl $198
80107082:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107087:	e9 e9 f1 ff ff       	jmp    80106275 <alltraps>

8010708c <vector199>:
.globl vector199
vector199:
  pushl $0
8010708c:	6a 00                	push   $0x0
  pushl $199
8010708e:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107093:	e9 dd f1 ff ff       	jmp    80106275 <alltraps>

80107098 <vector200>:
.globl vector200
vector200:
  pushl $0
80107098:	6a 00                	push   $0x0
  pushl $200
8010709a:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010709f:	e9 d1 f1 ff ff       	jmp    80106275 <alltraps>

801070a4 <vector201>:
.globl vector201
vector201:
  pushl $0
801070a4:	6a 00                	push   $0x0
  pushl $201
801070a6:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801070ab:	e9 c5 f1 ff ff       	jmp    80106275 <alltraps>

801070b0 <vector202>:
.globl vector202
vector202:
  pushl $0
801070b0:	6a 00                	push   $0x0
  pushl $202
801070b2:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801070b7:	e9 b9 f1 ff ff       	jmp    80106275 <alltraps>

801070bc <vector203>:
.globl vector203
vector203:
  pushl $0
801070bc:	6a 00                	push   $0x0
  pushl $203
801070be:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801070c3:	e9 ad f1 ff ff       	jmp    80106275 <alltraps>

801070c8 <vector204>:
.globl vector204
vector204:
  pushl $0
801070c8:	6a 00                	push   $0x0
  pushl $204
801070ca:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801070cf:	e9 a1 f1 ff ff       	jmp    80106275 <alltraps>

801070d4 <vector205>:
.globl vector205
vector205:
  pushl $0
801070d4:	6a 00                	push   $0x0
  pushl $205
801070d6:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801070db:	e9 95 f1 ff ff       	jmp    80106275 <alltraps>

801070e0 <vector206>:
.globl vector206
vector206:
  pushl $0
801070e0:	6a 00                	push   $0x0
  pushl $206
801070e2:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801070e7:	e9 89 f1 ff ff       	jmp    80106275 <alltraps>

801070ec <vector207>:
.globl vector207
vector207:
  pushl $0
801070ec:	6a 00                	push   $0x0
  pushl $207
801070ee:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801070f3:	e9 7d f1 ff ff       	jmp    80106275 <alltraps>

801070f8 <vector208>:
.globl vector208
vector208:
  pushl $0
801070f8:	6a 00                	push   $0x0
  pushl $208
801070fa:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801070ff:	e9 71 f1 ff ff       	jmp    80106275 <alltraps>

80107104 <vector209>:
.globl vector209
vector209:
  pushl $0
80107104:	6a 00                	push   $0x0
  pushl $209
80107106:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010710b:	e9 65 f1 ff ff       	jmp    80106275 <alltraps>

80107110 <vector210>:
.globl vector210
vector210:
  pushl $0
80107110:	6a 00                	push   $0x0
  pushl $210
80107112:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107117:	e9 59 f1 ff ff       	jmp    80106275 <alltraps>

8010711c <vector211>:
.globl vector211
vector211:
  pushl $0
8010711c:	6a 00                	push   $0x0
  pushl $211
8010711e:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107123:	e9 4d f1 ff ff       	jmp    80106275 <alltraps>

80107128 <vector212>:
.globl vector212
vector212:
  pushl $0
80107128:	6a 00                	push   $0x0
  pushl $212
8010712a:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010712f:	e9 41 f1 ff ff       	jmp    80106275 <alltraps>

80107134 <vector213>:
.globl vector213
vector213:
  pushl $0
80107134:	6a 00                	push   $0x0
  pushl $213
80107136:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010713b:	e9 35 f1 ff ff       	jmp    80106275 <alltraps>

80107140 <vector214>:
.globl vector214
vector214:
  pushl $0
80107140:	6a 00                	push   $0x0
  pushl $214
80107142:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107147:	e9 29 f1 ff ff       	jmp    80106275 <alltraps>

8010714c <vector215>:
.globl vector215
vector215:
  pushl $0
8010714c:	6a 00                	push   $0x0
  pushl $215
8010714e:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107153:	e9 1d f1 ff ff       	jmp    80106275 <alltraps>

80107158 <vector216>:
.globl vector216
vector216:
  pushl $0
80107158:	6a 00                	push   $0x0
  pushl $216
8010715a:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010715f:	e9 11 f1 ff ff       	jmp    80106275 <alltraps>

80107164 <vector217>:
.globl vector217
vector217:
  pushl $0
80107164:	6a 00                	push   $0x0
  pushl $217
80107166:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010716b:	e9 05 f1 ff ff       	jmp    80106275 <alltraps>

80107170 <vector218>:
.globl vector218
vector218:
  pushl $0
80107170:	6a 00                	push   $0x0
  pushl $218
80107172:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107177:	e9 f9 f0 ff ff       	jmp    80106275 <alltraps>

8010717c <vector219>:
.globl vector219
vector219:
  pushl $0
8010717c:	6a 00                	push   $0x0
  pushl $219
8010717e:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107183:	e9 ed f0 ff ff       	jmp    80106275 <alltraps>

80107188 <vector220>:
.globl vector220
vector220:
  pushl $0
80107188:	6a 00                	push   $0x0
  pushl $220
8010718a:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010718f:	e9 e1 f0 ff ff       	jmp    80106275 <alltraps>

80107194 <vector221>:
.globl vector221
vector221:
  pushl $0
80107194:	6a 00                	push   $0x0
  pushl $221
80107196:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010719b:	e9 d5 f0 ff ff       	jmp    80106275 <alltraps>

801071a0 <vector222>:
.globl vector222
vector222:
  pushl $0
801071a0:	6a 00                	push   $0x0
  pushl $222
801071a2:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801071a7:	e9 c9 f0 ff ff       	jmp    80106275 <alltraps>

801071ac <vector223>:
.globl vector223
vector223:
  pushl $0
801071ac:	6a 00                	push   $0x0
  pushl $223
801071ae:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801071b3:	e9 bd f0 ff ff       	jmp    80106275 <alltraps>

801071b8 <vector224>:
.globl vector224
vector224:
  pushl $0
801071b8:	6a 00                	push   $0x0
  pushl $224
801071ba:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801071bf:	e9 b1 f0 ff ff       	jmp    80106275 <alltraps>

801071c4 <vector225>:
.globl vector225
vector225:
  pushl $0
801071c4:	6a 00                	push   $0x0
  pushl $225
801071c6:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801071cb:	e9 a5 f0 ff ff       	jmp    80106275 <alltraps>

801071d0 <vector226>:
.globl vector226
vector226:
  pushl $0
801071d0:	6a 00                	push   $0x0
  pushl $226
801071d2:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801071d7:	e9 99 f0 ff ff       	jmp    80106275 <alltraps>

801071dc <vector227>:
.globl vector227
vector227:
  pushl $0
801071dc:	6a 00                	push   $0x0
  pushl $227
801071de:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801071e3:	e9 8d f0 ff ff       	jmp    80106275 <alltraps>

801071e8 <vector228>:
.globl vector228
vector228:
  pushl $0
801071e8:	6a 00                	push   $0x0
  pushl $228
801071ea:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801071ef:	e9 81 f0 ff ff       	jmp    80106275 <alltraps>

801071f4 <vector229>:
.globl vector229
vector229:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $229
801071f6:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801071fb:	e9 75 f0 ff ff       	jmp    80106275 <alltraps>

80107200 <vector230>:
.globl vector230
vector230:
  pushl $0
80107200:	6a 00                	push   $0x0
  pushl $230
80107202:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107207:	e9 69 f0 ff ff       	jmp    80106275 <alltraps>

8010720c <vector231>:
.globl vector231
vector231:
  pushl $0
8010720c:	6a 00                	push   $0x0
  pushl $231
8010720e:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107213:	e9 5d f0 ff ff       	jmp    80106275 <alltraps>

80107218 <vector232>:
.globl vector232
vector232:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $232
8010721a:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010721f:	e9 51 f0 ff ff       	jmp    80106275 <alltraps>

80107224 <vector233>:
.globl vector233
vector233:
  pushl $0
80107224:	6a 00                	push   $0x0
  pushl $233
80107226:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010722b:	e9 45 f0 ff ff       	jmp    80106275 <alltraps>

80107230 <vector234>:
.globl vector234
vector234:
  pushl $0
80107230:	6a 00                	push   $0x0
  pushl $234
80107232:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107237:	e9 39 f0 ff ff       	jmp    80106275 <alltraps>

8010723c <vector235>:
.globl vector235
vector235:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $235
8010723e:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107243:	e9 2d f0 ff ff       	jmp    80106275 <alltraps>

80107248 <vector236>:
.globl vector236
vector236:
  pushl $0
80107248:	6a 00                	push   $0x0
  pushl $236
8010724a:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010724f:	e9 21 f0 ff ff       	jmp    80106275 <alltraps>

80107254 <vector237>:
.globl vector237
vector237:
  pushl $0
80107254:	6a 00                	push   $0x0
  pushl $237
80107256:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010725b:	e9 15 f0 ff ff       	jmp    80106275 <alltraps>

80107260 <vector238>:
.globl vector238
vector238:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $238
80107262:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107267:	e9 09 f0 ff ff       	jmp    80106275 <alltraps>

8010726c <vector239>:
.globl vector239
vector239:
  pushl $0
8010726c:	6a 00                	push   $0x0
  pushl $239
8010726e:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107273:	e9 fd ef ff ff       	jmp    80106275 <alltraps>

80107278 <vector240>:
.globl vector240
vector240:
  pushl $0
80107278:	6a 00                	push   $0x0
  pushl $240
8010727a:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010727f:	e9 f1 ef ff ff       	jmp    80106275 <alltraps>

80107284 <vector241>:
.globl vector241
vector241:
  pushl $0
80107284:	6a 00                	push   $0x0
  pushl $241
80107286:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010728b:	e9 e5 ef ff ff       	jmp    80106275 <alltraps>

80107290 <vector242>:
.globl vector242
vector242:
  pushl $0
80107290:	6a 00                	push   $0x0
  pushl $242
80107292:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107297:	e9 d9 ef ff ff       	jmp    80106275 <alltraps>

8010729c <vector243>:
.globl vector243
vector243:
  pushl $0
8010729c:	6a 00                	push   $0x0
  pushl $243
8010729e:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801072a3:	e9 cd ef ff ff       	jmp    80106275 <alltraps>

801072a8 <vector244>:
.globl vector244
vector244:
  pushl $0
801072a8:	6a 00                	push   $0x0
  pushl $244
801072aa:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801072af:	e9 c1 ef ff ff       	jmp    80106275 <alltraps>

801072b4 <vector245>:
.globl vector245
vector245:
  pushl $0
801072b4:	6a 00                	push   $0x0
  pushl $245
801072b6:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801072bb:	e9 b5 ef ff ff       	jmp    80106275 <alltraps>

801072c0 <vector246>:
.globl vector246
vector246:
  pushl $0
801072c0:	6a 00                	push   $0x0
  pushl $246
801072c2:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801072c7:	e9 a9 ef ff ff       	jmp    80106275 <alltraps>

801072cc <vector247>:
.globl vector247
vector247:
  pushl $0
801072cc:	6a 00                	push   $0x0
  pushl $247
801072ce:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801072d3:	e9 9d ef ff ff       	jmp    80106275 <alltraps>

801072d8 <vector248>:
.globl vector248
vector248:
  pushl $0
801072d8:	6a 00                	push   $0x0
  pushl $248
801072da:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801072df:	e9 91 ef ff ff       	jmp    80106275 <alltraps>

801072e4 <vector249>:
.globl vector249
vector249:
  pushl $0
801072e4:	6a 00                	push   $0x0
  pushl $249
801072e6:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801072eb:	e9 85 ef ff ff       	jmp    80106275 <alltraps>

801072f0 <vector250>:
.globl vector250
vector250:
  pushl $0
801072f0:	6a 00                	push   $0x0
  pushl $250
801072f2:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801072f7:	e9 79 ef ff ff       	jmp    80106275 <alltraps>

801072fc <vector251>:
.globl vector251
vector251:
  pushl $0
801072fc:	6a 00                	push   $0x0
  pushl $251
801072fe:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107303:	e9 6d ef ff ff       	jmp    80106275 <alltraps>

80107308 <vector252>:
.globl vector252
vector252:
  pushl $0
80107308:	6a 00                	push   $0x0
  pushl $252
8010730a:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010730f:	e9 61 ef ff ff       	jmp    80106275 <alltraps>

80107314 <vector253>:
.globl vector253
vector253:
  pushl $0
80107314:	6a 00                	push   $0x0
  pushl $253
80107316:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010731b:	e9 55 ef ff ff       	jmp    80106275 <alltraps>

80107320 <vector254>:
.globl vector254
vector254:
  pushl $0
80107320:	6a 00                	push   $0x0
  pushl $254
80107322:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107327:	e9 49 ef ff ff       	jmp    80106275 <alltraps>

8010732c <vector255>:
.globl vector255
vector255:
  pushl $0
8010732c:	6a 00                	push   $0x0
  pushl $255
8010732e:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107333:	e9 3d ef ff ff       	jmp    80106275 <alltraps>

80107338 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107338:	55                   	push   %ebp
80107339:	89 e5                	mov    %esp,%ebp
8010733b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010733e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107341:	83 e8 01             	sub    $0x1,%eax
80107344:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107348:	8b 45 08             	mov    0x8(%ebp),%eax
8010734b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010734f:	8b 45 08             	mov    0x8(%ebp),%eax
80107352:	c1 e8 10             	shr    $0x10,%eax
80107355:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107359:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010735c:	0f 01 10             	lgdtl  (%eax)
}
8010735f:	90                   	nop
80107360:	c9                   	leave  
80107361:	c3                   	ret    

80107362 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107362:	55                   	push   %ebp
80107363:	89 e5                	mov    %esp,%ebp
80107365:	83 ec 04             	sub    $0x4,%esp
80107368:	8b 45 08             	mov    0x8(%ebp),%eax
8010736b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010736f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107373:	0f 00 d8             	ltr    %ax
}
80107376:	90                   	nop
80107377:	c9                   	leave  
80107378:	c3                   	ret    

80107379 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107379:	55                   	push   %ebp
8010737a:	89 e5                	mov    %esp,%ebp
8010737c:	83 ec 04             	sub    $0x4,%esp
8010737f:	8b 45 08             	mov    0x8(%ebp),%eax
80107382:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107386:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010738a:	8e e8                	mov    %eax,%gs
}
8010738c:	90                   	nop
8010738d:	c9                   	leave  
8010738e:	c3                   	ret    

8010738f <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010738f:	55                   	push   %ebp
80107390:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107392:	8b 45 08             	mov    0x8(%ebp),%eax
80107395:	0f 22 d8             	mov    %eax,%cr3
}
80107398:	90                   	nop
80107399:	5d                   	pop    %ebp
8010739a:	c3                   	ret    

8010739b <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010739b:	55                   	push   %ebp
8010739c:	89 e5                	mov    %esp,%ebp
8010739e:	8b 45 08             	mov    0x8(%ebp),%eax
801073a1:	05 00 00 00 80       	add    $0x80000000,%eax
801073a6:	5d                   	pop    %ebp
801073a7:	c3                   	ret    

801073a8 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801073a8:	55                   	push   %ebp
801073a9:	89 e5                	mov    %esp,%ebp
801073ab:	8b 45 08             	mov    0x8(%ebp),%eax
801073ae:	05 00 00 00 80       	add    $0x80000000,%eax
801073b3:	5d                   	pop    %ebp
801073b4:	c3                   	ret    

801073b5 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801073b5:	55                   	push   %ebp
801073b6:	89 e5                	mov    %esp,%ebp
801073b8:	53                   	push   %ebx
801073b9:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801073bc:	e8 39 bb ff ff       	call   80102efa <cpunum>
801073c1:	89 c2                	mov    %eax,%edx
801073c3:	89 d0                	mov    %edx,%eax
801073c5:	01 c0                	add    %eax,%eax
801073c7:	01 d0                	add    %edx,%eax
801073c9:	c1 e0 06             	shl    $0x6,%eax
801073cc:	05 40 f9 10 80       	add    $0x8010f940,%eax
801073d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801073d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d7:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801073dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e0:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801073e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e9:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801073ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073f4:	83 e2 f0             	and    $0xfffffff0,%edx
801073f7:	83 ca 0a             	or     $0xa,%edx
801073fa:	88 50 7d             	mov    %dl,0x7d(%eax)
801073fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107400:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107404:	83 ca 10             	or     $0x10,%edx
80107407:	88 50 7d             	mov    %dl,0x7d(%eax)
8010740a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010740d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107411:	83 e2 9f             	and    $0xffffff9f,%edx
80107414:	88 50 7d             	mov    %dl,0x7d(%eax)
80107417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010741e:	83 ca 80             	or     $0xffffff80,%edx
80107421:	88 50 7d             	mov    %dl,0x7d(%eax)
80107424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107427:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010742b:	83 ca 0f             	or     $0xf,%edx
8010742e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107434:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107438:	83 e2 ef             	and    $0xffffffef,%edx
8010743b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010743e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107441:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107445:	83 e2 df             	and    $0xffffffdf,%edx
80107448:	88 50 7e             	mov    %dl,0x7e(%eax)
8010744b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010744e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107452:	83 ca 40             	or     $0x40,%edx
80107455:	88 50 7e             	mov    %dl,0x7e(%eax)
80107458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010745b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010745f:	83 ca 80             	or     $0xffffff80,%edx
80107462:	88 50 7e             	mov    %dl,0x7e(%eax)
80107465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107468:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010746c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010746f:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107476:	ff ff 
80107478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747b:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107482:	00 00 
80107484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107487:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010748e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107491:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107498:	83 e2 f0             	and    $0xfffffff0,%edx
8010749b:	83 ca 02             	or     $0x2,%edx
8010749e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a7:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074ae:	83 ca 10             	or     $0x10,%edx
801074b1:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ba:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074c1:	83 e2 9f             	and    $0xffffff9f,%edx
801074c4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074cd:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074d4:	83 ca 80             	or     $0xffffff80,%edx
801074d7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074e7:	83 ca 0f             	or     $0xf,%edx
801074ea:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074fa:	83 e2 ef             	and    $0xffffffef,%edx
801074fd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107506:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010750d:	83 e2 df             	and    $0xffffffdf,%edx
80107510:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107516:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107519:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107520:	83 ca 40             	or     $0x40,%edx
80107523:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107533:	83 ca 80             	or     $0xffffff80,%edx
80107536:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010753c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753f:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107546:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107549:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107550:	ff ff 
80107552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107555:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010755c:	00 00 
8010755e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107561:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107568:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010756b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107572:	83 e2 f0             	and    $0xfffffff0,%edx
80107575:	83 ca 0a             	or     $0xa,%edx
80107578:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010757e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107581:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107588:	83 ca 10             	or     $0x10,%edx
8010758b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107594:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010759b:	83 ca 60             	or     $0x60,%edx
8010759e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075ae:	83 ca 80             	or     $0xffffff80,%edx
801075b1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ba:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801075c1:	83 ca 0f             	or     $0xf,%edx
801075c4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801075ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075cd:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801075d4:	83 e2 ef             	and    $0xffffffef,%edx
801075d7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801075dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801075e7:	83 e2 df             	and    $0xffffffdf,%edx
801075ea:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801075f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801075fa:	83 ca 40             	or     $0x40,%edx
801075fd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107606:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010760d:	83 ca 80             	or     $0xffffff80,%edx
80107610:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107619:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107623:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
8010762a:	ff ff 
8010762c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762f:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107636:	00 00 
80107638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763b:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107645:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010764c:	83 e2 f0             	and    $0xfffffff0,%edx
8010764f:	83 ca 02             	or     $0x2,%edx
80107652:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010765b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107662:	83 ca 10             	or     $0x10,%edx
80107665:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010766b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107675:	83 ca 60             	or     $0x60,%edx
80107678:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010767e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107681:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107688:	83 ca 80             	or     $0xffffff80,%edx
8010768b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107694:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010769b:	83 ca 0f             	or     $0xf,%edx
8010769e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801076a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801076ae:	83 e2 ef             	and    $0xffffffef,%edx
801076b1:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801076b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ba:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801076c1:	83 e2 df             	and    $0xffffffdf,%edx
801076c4:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801076ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cd:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801076d4:	83 ca 40             	or     $0x40,%edx
801076d7:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801076dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e0:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801076e7:	83 ca 80             	or     $0xffffff80,%edx
801076ea:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801076f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f3:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801076fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fd:	05 b8 00 00 00       	add    $0xb8,%eax
80107702:	89 c3                	mov    %eax,%ebx
80107704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107707:	05 b8 00 00 00       	add    $0xb8,%eax
8010770c:	c1 e8 10             	shr    $0x10,%eax
8010770f:	89 c2                	mov    %eax,%edx
80107711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107714:	05 b8 00 00 00       	add    $0xb8,%eax
80107719:	c1 e8 18             	shr    $0x18,%eax
8010771c:	89 c1                	mov    %eax,%ecx
8010771e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107721:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107728:	00 00 
8010772a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772d:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107737:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
8010773d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107740:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107747:	83 e2 f0             	and    $0xfffffff0,%edx
8010774a:	83 ca 02             	or     $0x2,%edx
8010774d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107756:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010775d:	83 ca 10             	or     $0x10,%edx
80107760:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107769:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107770:	83 e2 9f             	and    $0xffffff9f,%edx
80107773:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107783:	83 ca 80             	or     $0xffffff80,%edx
80107786:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010778c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107796:	83 e2 f0             	and    $0xfffffff0,%edx
80107799:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010779f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077a9:	83 e2 ef             	and    $0xffffffef,%edx
801077ac:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077bc:	83 e2 df             	and    $0xffffffdf,%edx
801077bf:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077cf:	83 ca 40             	or     $0x40,%edx
801077d2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077db:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077e2:	83 ca 80             	or     $0xffffff80,%edx
801077e5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ee:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801077f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f7:	83 c0 70             	add    $0x70,%eax
801077fa:	83 ec 08             	sub    $0x8,%esp
801077fd:	6a 38                	push   $0x38
801077ff:	50                   	push   %eax
80107800:	e8 33 fb ff ff       	call   80107338 <lgdt>
80107805:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107808:	83 ec 0c             	sub    $0xc,%esp
8010780b:	6a 18                	push   $0x18
8010780d:	e8 67 fb ff ff       	call   80107379 <loadgs>
80107812:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107818:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
8010781e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107825:	00 00 00 00 
}
80107829:	90                   	nop
8010782a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010782d:	c9                   	leave  
8010782e:	c3                   	ret    

8010782f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010782f:	55                   	push   %ebp
80107830:	89 e5                	mov    %esp,%ebp
80107832:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107835:	8b 45 0c             	mov    0xc(%ebp),%eax
80107838:	c1 e8 16             	shr    $0x16,%eax
8010783b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107842:	8b 45 08             	mov    0x8(%ebp),%eax
80107845:	01 d0                	add    %edx,%eax
80107847:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010784a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010784d:	8b 00                	mov    (%eax),%eax
8010784f:	83 e0 01             	and    $0x1,%eax
80107852:	85 c0                	test   %eax,%eax
80107854:	74 18                	je     8010786e <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107856:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107859:	8b 00                	mov    (%eax),%eax
8010785b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107860:	50                   	push   %eax
80107861:	e8 42 fb ff ff       	call   801073a8 <p2v>
80107866:	83 c4 04             	add    $0x4,%esp
80107869:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010786c:	eb 48                	jmp    801078b6 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010786e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107872:	74 0e                	je     80107882 <walkpgdir+0x53>
80107874:	e8 38 b3 ff ff       	call   80102bb1 <kalloc>
80107879:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010787c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107880:	75 07                	jne    80107889 <walkpgdir+0x5a>
      return 0;
80107882:	b8 00 00 00 00       	mov    $0x0,%eax
80107887:	eb 44                	jmp    801078cd <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107889:	83 ec 04             	sub    $0x4,%esp
8010788c:	68 00 10 00 00       	push   $0x1000
80107891:	6a 00                	push   $0x0
80107893:	ff 75 f4             	pushl  -0xc(%ebp)
80107896:	e8 8e d5 ff ff       	call   80104e29 <memset>
8010789b:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
8010789e:	83 ec 0c             	sub    $0xc,%esp
801078a1:	ff 75 f4             	pushl  -0xc(%ebp)
801078a4:	e8 f2 fa ff ff       	call   8010739b <v2p>
801078a9:	83 c4 10             	add    $0x10,%esp
801078ac:	83 c8 07             	or     $0x7,%eax
801078af:	89 c2                	mov    %eax,%edx
801078b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078b4:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801078b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801078b9:	c1 e8 0c             	shr    $0xc,%eax
801078bc:	25 ff 03 00 00       	and    $0x3ff,%eax
801078c1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cb:	01 d0                	add    %edx,%eax
}
801078cd:	c9                   	leave  
801078ce:	c3                   	ret    

801078cf <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801078cf:	55                   	push   %ebp
801078d0:	89 e5                	mov    %esp,%ebp
801078d2:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
801078d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801078d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801078e0:	8b 55 0c             	mov    0xc(%ebp),%edx
801078e3:	8b 45 10             	mov    0x10(%ebp),%eax
801078e6:	01 d0                	add    %edx,%eax
801078e8:	83 e8 01             	sub    $0x1,%eax
801078eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801078f3:	83 ec 04             	sub    $0x4,%esp
801078f6:	6a 01                	push   $0x1
801078f8:	ff 75 f4             	pushl  -0xc(%ebp)
801078fb:	ff 75 08             	pushl  0x8(%ebp)
801078fe:	e8 2c ff ff ff       	call   8010782f <walkpgdir>
80107903:	83 c4 10             	add    $0x10,%esp
80107906:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107909:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010790d:	75 07                	jne    80107916 <mappages+0x47>
      return -1;
8010790f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107914:	eb 47                	jmp    8010795d <mappages+0x8e>
    if(*pte & PTE_P)
80107916:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107919:	8b 00                	mov    (%eax),%eax
8010791b:	83 e0 01             	and    $0x1,%eax
8010791e:	85 c0                	test   %eax,%eax
80107920:	74 0d                	je     8010792f <mappages+0x60>
      panic("remap");
80107922:	83 ec 0c             	sub    $0xc,%esp
80107925:	68 04 87 10 80       	push   $0x80108704
8010792a:	e8 37 8c ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
8010792f:	8b 45 18             	mov    0x18(%ebp),%eax
80107932:	0b 45 14             	or     0x14(%ebp),%eax
80107935:	83 c8 01             	or     $0x1,%eax
80107938:	89 c2                	mov    %eax,%edx
8010793a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010793d:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010793f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107942:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107945:	74 10                	je     80107957 <mappages+0x88>
      break;
    a += PGSIZE;
80107947:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010794e:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107955:	eb 9c                	jmp    801078f3 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107957:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107958:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010795d:	c9                   	leave  
8010795e:	c3                   	ret    

8010795f <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010795f:	55                   	push   %ebp
80107960:	89 e5                	mov    %esp,%ebp
80107962:	53                   	push   %ebx
80107963:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107966:	e8 46 b2 ff ff       	call   80102bb1 <kalloc>
8010796b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010796e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107972:	75 0a                	jne    8010797e <setupkvm+0x1f>
    return 0;
80107974:	b8 00 00 00 00       	mov    $0x0,%eax
80107979:	e9 8e 00 00 00       	jmp    80107a0c <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
8010797e:	83 ec 04             	sub    $0x4,%esp
80107981:	68 00 10 00 00       	push   $0x1000
80107986:	6a 00                	push   $0x0
80107988:	ff 75 f0             	pushl  -0x10(%ebp)
8010798b:	e8 99 d4 ff ff       	call   80104e29 <memset>
80107990:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107993:	83 ec 0c             	sub    $0xc,%esp
80107996:	68 00 00 00 0e       	push   $0xe000000
8010799b:	e8 08 fa ff ff       	call   801073a8 <p2v>
801079a0:	83 c4 10             	add    $0x10,%esp
801079a3:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
801079a8:	76 0d                	jbe    801079b7 <setupkvm+0x58>
    panic("PHYSTOP too high");
801079aa:	83 ec 0c             	sub    $0xc,%esp
801079ad:	68 0a 87 10 80       	push   $0x8010870a
801079b2:	e8 af 8b ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801079b7:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
801079be:	eb 40                	jmp    80107a00 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801079c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c3:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
801079c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c9:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801079cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cf:	8b 58 08             	mov    0x8(%eax),%ebx
801079d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d5:	8b 40 04             	mov    0x4(%eax),%eax
801079d8:	29 c3                	sub    %eax,%ebx
801079da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079dd:	8b 00                	mov    (%eax),%eax
801079df:	83 ec 0c             	sub    $0xc,%esp
801079e2:	51                   	push   %ecx
801079e3:	52                   	push   %edx
801079e4:	53                   	push   %ebx
801079e5:	50                   	push   %eax
801079e6:	ff 75 f0             	pushl  -0x10(%ebp)
801079e9:	e8 e1 fe ff ff       	call   801078cf <mappages>
801079ee:	83 c4 20             	add    $0x20,%esp
801079f1:	85 c0                	test   %eax,%eax
801079f3:	79 07                	jns    801079fc <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801079f5:	b8 00 00 00 00       	mov    $0x0,%eax
801079fa:	eb 10                	jmp    80107a0c <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801079fc:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107a00:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
80107a07:	72 b7                	jb     801079c0 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107a0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107a0f:	c9                   	leave  
80107a10:	c3                   	ret    

80107a11 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107a11:	55                   	push   %ebp
80107a12:	89 e5                	mov    %esp,%ebp
80107a14:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107a17:	e8 43 ff ff ff       	call   8010795f <setupkvm>
80107a1c:	a3 38 27 11 80       	mov    %eax,0x80112738
  switchkvm();
80107a21:	e8 03 00 00 00       	call   80107a29 <switchkvm>
}
80107a26:	90                   	nop
80107a27:	c9                   	leave  
80107a28:	c3                   	ret    

80107a29 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107a29:	55                   	push   %ebp
80107a2a:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107a2c:	a1 38 27 11 80       	mov    0x80112738,%eax
80107a31:	50                   	push   %eax
80107a32:	e8 64 f9 ff ff       	call   8010739b <v2p>
80107a37:	83 c4 04             	add    $0x4,%esp
80107a3a:	50                   	push   %eax
80107a3b:	e8 4f f9 ff ff       	call   8010738f <lcr3>
80107a40:	83 c4 04             	add    $0x4,%esp
}
80107a43:	90                   	nop
80107a44:	c9                   	leave  
80107a45:	c3                   	ret    

80107a46 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107a46:	55                   	push   %ebp
80107a47:	89 e5                	mov    %esp,%ebp
80107a49:	56                   	push   %esi
80107a4a:	53                   	push   %ebx
  pushcli();
80107a4b:	e8 d3 d2 ff ff       	call   80104d23 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107a50:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a56:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107a5d:	83 c2 08             	add    $0x8,%edx
80107a60:	89 d6                	mov    %edx,%esi
80107a62:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107a69:	83 c2 08             	add    $0x8,%edx
80107a6c:	c1 ea 10             	shr    $0x10,%edx
80107a6f:	89 d3                	mov    %edx,%ebx
80107a71:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107a78:	83 c2 08             	add    $0x8,%edx
80107a7b:	c1 ea 18             	shr    $0x18,%edx
80107a7e:	89 d1                	mov    %edx,%ecx
80107a80:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107a87:	67 00 
80107a89:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80107a90:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80107a96:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107a9d:	83 e2 f0             	and    $0xfffffff0,%edx
80107aa0:	83 ca 09             	or     $0x9,%edx
80107aa3:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107aa9:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107ab0:	83 ca 10             	or     $0x10,%edx
80107ab3:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107ab9:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107ac0:	83 e2 9f             	and    $0xffffff9f,%edx
80107ac3:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107ac9:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107ad0:	83 ca 80             	or     $0xffffff80,%edx
80107ad3:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107ad9:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107ae0:	83 e2 f0             	and    $0xfffffff0,%edx
80107ae3:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107ae9:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107af0:	83 e2 ef             	and    $0xffffffef,%edx
80107af3:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107af9:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107b00:	83 e2 df             	and    $0xffffffdf,%edx
80107b03:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107b09:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107b10:	83 ca 40             	or     $0x40,%edx
80107b13:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107b19:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107b20:	83 e2 7f             	and    $0x7f,%edx
80107b23:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107b29:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107b2f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107b35:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107b3c:	83 e2 ef             	and    $0xffffffef,%edx
80107b3f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107b45:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107b4b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107b51:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107b57:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107b5e:	8b 52 08             	mov    0x8(%edx),%edx
80107b61:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107b67:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107b6a:	83 ec 0c             	sub    $0xc,%esp
80107b6d:	6a 30                	push   $0x30
80107b6f:	e8 ee f7 ff ff       	call   80107362 <ltr>
80107b74:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80107b77:	8b 45 08             	mov    0x8(%ebp),%eax
80107b7a:	8b 40 04             	mov    0x4(%eax),%eax
80107b7d:	85 c0                	test   %eax,%eax
80107b7f:	75 0d                	jne    80107b8e <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80107b81:	83 ec 0c             	sub    $0xc,%esp
80107b84:	68 1b 87 10 80       	push   $0x8010871b
80107b89:	e8 d8 89 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107b8e:	8b 45 08             	mov    0x8(%ebp),%eax
80107b91:	8b 40 04             	mov    0x4(%eax),%eax
80107b94:	83 ec 0c             	sub    $0xc,%esp
80107b97:	50                   	push   %eax
80107b98:	e8 fe f7 ff ff       	call   8010739b <v2p>
80107b9d:	83 c4 10             	add    $0x10,%esp
80107ba0:	83 ec 0c             	sub    $0xc,%esp
80107ba3:	50                   	push   %eax
80107ba4:	e8 e6 f7 ff ff       	call   8010738f <lcr3>
80107ba9:	83 c4 10             	add    $0x10,%esp
  popcli();
80107bac:	e8 b7 d1 ff ff       	call   80104d68 <popcli>
}
80107bb1:	90                   	nop
80107bb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107bb5:	5b                   	pop    %ebx
80107bb6:	5e                   	pop    %esi
80107bb7:	5d                   	pop    %ebp
80107bb8:	c3                   	ret    

80107bb9 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107bb9:	55                   	push   %ebp
80107bba:	89 e5                	mov    %esp,%ebp
80107bbc:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107bbf:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107bc6:	76 0d                	jbe    80107bd5 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107bc8:	83 ec 0c             	sub    $0xc,%esp
80107bcb:	68 2f 87 10 80       	push   $0x8010872f
80107bd0:	e8 91 89 ff ff       	call   80100566 <panic>
  mem = kalloc();
80107bd5:	e8 d7 af ff ff       	call   80102bb1 <kalloc>
80107bda:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107bdd:	83 ec 04             	sub    $0x4,%esp
80107be0:	68 00 10 00 00       	push   $0x1000
80107be5:	6a 00                	push   $0x0
80107be7:	ff 75 f4             	pushl  -0xc(%ebp)
80107bea:	e8 3a d2 ff ff       	call   80104e29 <memset>
80107bef:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107bf2:	83 ec 0c             	sub    $0xc,%esp
80107bf5:	ff 75 f4             	pushl  -0xc(%ebp)
80107bf8:	e8 9e f7 ff ff       	call   8010739b <v2p>
80107bfd:	83 c4 10             	add    $0x10,%esp
80107c00:	83 ec 0c             	sub    $0xc,%esp
80107c03:	6a 06                	push   $0x6
80107c05:	50                   	push   %eax
80107c06:	68 00 10 00 00       	push   $0x1000
80107c0b:	6a 00                	push   $0x0
80107c0d:	ff 75 08             	pushl  0x8(%ebp)
80107c10:	e8 ba fc ff ff       	call   801078cf <mappages>
80107c15:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107c18:	83 ec 04             	sub    $0x4,%esp
80107c1b:	ff 75 10             	pushl  0x10(%ebp)
80107c1e:	ff 75 0c             	pushl  0xc(%ebp)
80107c21:	ff 75 f4             	pushl  -0xc(%ebp)
80107c24:	e8 bf d2 ff ff       	call   80104ee8 <memmove>
80107c29:	83 c4 10             	add    $0x10,%esp
}
80107c2c:	90                   	nop
80107c2d:	c9                   	leave  
80107c2e:	c3                   	ret    

80107c2f <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107c2f:	55                   	push   %ebp
80107c30:	89 e5                	mov    %esp,%ebp
80107c32:	53                   	push   %ebx
80107c33:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107c36:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c39:	25 ff 0f 00 00       	and    $0xfff,%eax
80107c3e:	85 c0                	test   %eax,%eax
80107c40:	74 0d                	je     80107c4f <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80107c42:	83 ec 0c             	sub    $0xc,%esp
80107c45:	68 4c 87 10 80       	push   $0x8010874c
80107c4a:	e8 17 89 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107c4f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c56:	e9 95 00 00 00       	jmp    80107cf0 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107c5b:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c61:	01 d0                	add    %edx,%eax
80107c63:	83 ec 04             	sub    $0x4,%esp
80107c66:	6a 00                	push   $0x0
80107c68:	50                   	push   %eax
80107c69:	ff 75 08             	pushl  0x8(%ebp)
80107c6c:	e8 be fb ff ff       	call   8010782f <walkpgdir>
80107c71:	83 c4 10             	add    $0x10,%esp
80107c74:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c77:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c7b:	75 0d                	jne    80107c8a <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80107c7d:	83 ec 0c             	sub    $0xc,%esp
80107c80:	68 6f 87 10 80       	push   $0x8010876f
80107c85:	e8 dc 88 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80107c8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c8d:	8b 00                	mov    (%eax),%eax
80107c8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c94:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107c97:	8b 45 18             	mov    0x18(%ebp),%eax
80107c9a:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107c9d:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107ca2:	77 0b                	ja     80107caf <loaduvm+0x80>
      n = sz - i;
80107ca4:	8b 45 18             	mov    0x18(%ebp),%eax
80107ca7:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107caa:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107cad:	eb 07                	jmp    80107cb6 <loaduvm+0x87>
    else
      n = PGSIZE;
80107caf:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80107cb6:	8b 55 14             	mov    0x14(%ebp),%edx
80107cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbc:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80107cbf:	83 ec 0c             	sub    $0xc,%esp
80107cc2:	ff 75 e8             	pushl  -0x18(%ebp)
80107cc5:	e8 de f6 ff ff       	call   801073a8 <p2v>
80107cca:	83 c4 10             	add    $0x10,%esp
80107ccd:	ff 75 f0             	pushl  -0x10(%ebp)
80107cd0:	53                   	push   %ebx
80107cd1:	50                   	push   %eax
80107cd2:	ff 75 10             	pushl  0x10(%ebp)
80107cd5:	e8 85 a1 ff ff       	call   80101e5f <readi>
80107cda:	83 c4 10             	add    $0x10,%esp
80107cdd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107ce0:	74 07                	je     80107ce9 <loaduvm+0xba>
      return -1;
80107ce2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ce7:	eb 18                	jmp    80107d01 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107ce9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf3:	3b 45 18             	cmp    0x18(%ebp),%eax
80107cf6:	0f 82 5f ff ff ff    	jb     80107c5b <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107cfc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107d04:	c9                   	leave  
80107d05:	c3                   	ret    

80107d06 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d06:	55                   	push   %ebp
80107d07:	89 e5                	mov    %esp,%ebp
80107d09:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107d0c:	8b 45 10             	mov    0x10(%ebp),%eax
80107d0f:	85 c0                	test   %eax,%eax
80107d11:	79 0a                	jns    80107d1d <allocuvm+0x17>
    return 0;
80107d13:	b8 00 00 00 00       	mov    $0x0,%eax
80107d18:	e9 b0 00 00 00       	jmp    80107dcd <allocuvm+0xc7>
  if(newsz < oldsz)
80107d1d:	8b 45 10             	mov    0x10(%ebp),%eax
80107d20:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d23:	73 08                	jae    80107d2d <allocuvm+0x27>
    return oldsz;
80107d25:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d28:	e9 a0 00 00 00       	jmp    80107dcd <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80107d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d30:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d35:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107d3d:	eb 7f                	jmp    80107dbe <allocuvm+0xb8>
    mem = kalloc();
80107d3f:	e8 6d ae ff ff       	call   80102bb1 <kalloc>
80107d44:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107d47:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d4b:	75 2b                	jne    80107d78 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80107d4d:	83 ec 0c             	sub    $0xc,%esp
80107d50:	68 8d 87 10 80       	push   $0x8010878d
80107d55:	e8 6c 86 ff ff       	call   801003c6 <cprintf>
80107d5a:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107d5d:	83 ec 04             	sub    $0x4,%esp
80107d60:	ff 75 0c             	pushl  0xc(%ebp)
80107d63:	ff 75 10             	pushl  0x10(%ebp)
80107d66:	ff 75 08             	pushl  0x8(%ebp)
80107d69:	e8 61 00 00 00       	call   80107dcf <deallocuvm>
80107d6e:	83 c4 10             	add    $0x10,%esp
      return 0;
80107d71:	b8 00 00 00 00       	mov    $0x0,%eax
80107d76:	eb 55                	jmp    80107dcd <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80107d78:	83 ec 04             	sub    $0x4,%esp
80107d7b:	68 00 10 00 00       	push   $0x1000
80107d80:	6a 00                	push   $0x0
80107d82:	ff 75 f0             	pushl  -0x10(%ebp)
80107d85:	e8 9f d0 ff ff       	call   80104e29 <memset>
80107d8a:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107d8d:	83 ec 0c             	sub    $0xc,%esp
80107d90:	ff 75 f0             	pushl  -0x10(%ebp)
80107d93:	e8 03 f6 ff ff       	call   8010739b <v2p>
80107d98:	83 c4 10             	add    $0x10,%esp
80107d9b:	89 c2                	mov    %eax,%edx
80107d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da0:	83 ec 0c             	sub    $0xc,%esp
80107da3:	6a 06                	push   $0x6
80107da5:	52                   	push   %edx
80107da6:	68 00 10 00 00       	push   $0x1000
80107dab:	50                   	push   %eax
80107dac:	ff 75 08             	pushl  0x8(%ebp)
80107daf:	e8 1b fb ff ff       	call   801078cf <mappages>
80107db4:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80107db7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc1:	3b 45 10             	cmp    0x10(%ebp),%eax
80107dc4:	0f 82 75 ff ff ff    	jb     80107d3f <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80107dca:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107dcd:	c9                   	leave  
80107dce:	c3                   	ret    

80107dcf <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107dcf:	55                   	push   %ebp
80107dd0:	89 e5                	mov    %esp,%ebp
80107dd2:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107dd5:	8b 45 10             	mov    0x10(%ebp),%eax
80107dd8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ddb:	72 08                	jb     80107de5 <deallocuvm+0x16>
    return oldsz;
80107ddd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107de0:	e9 a5 00 00 00       	jmp    80107e8a <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80107de5:	8b 45 10             	mov    0x10(%ebp),%eax
80107de8:	05 ff 0f 00 00       	add    $0xfff,%eax
80107ded:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107df2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107df5:	e9 81 00 00 00       	jmp    80107e7b <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfd:	83 ec 04             	sub    $0x4,%esp
80107e00:	6a 00                	push   $0x0
80107e02:	50                   	push   %eax
80107e03:	ff 75 08             	pushl  0x8(%ebp)
80107e06:	e8 24 fa ff ff       	call   8010782f <walkpgdir>
80107e0b:	83 c4 10             	add    $0x10,%esp
80107e0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107e11:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e15:	75 09                	jne    80107e20 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80107e17:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80107e1e:	eb 54                	jmp    80107e74 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80107e20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e23:	8b 00                	mov    (%eax),%eax
80107e25:	83 e0 01             	and    $0x1,%eax
80107e28:	85 c0                	test   %eax,%eax
80107e2a:	74 48                	je     80107e74 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80107e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e2f:	8b 00                	mov    (%eax),%eax
80107e31:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e36:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107e39:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e3d:	75 0d                	jne    80107e4c <deallocuvm+0x7d>
        panic("kfree");
80107e3f:	83 ec 0c             	sub    $0xc,%esp
80107e42:	68 a5 87 10 80       	push   $0x801087a5
80107e47:	e8 1a 87 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80107e4c:	83 ec 0c             	sub    $0xc,%esp
80107e4f:	ff 75 ec             	pushl  -0x14(%ebp)
80107e52:	e8 51 f5 ff ff       	call   801073a8 <p2v>
80107e57:	83 c4 10             	add    $0x10,%esp
80107e5a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107e5d:	83 ec 0c             	sub    $0xc,%esp
80107e60:	ff 75 e8             	pushl  -0x18(%ebp)
80107e63:	e8 ac ac ff ff       	call   80102b14 <kfree>
80107e68:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e6e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80107e74:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e81:	0f 82 73 ff ff ff    	jb     80107dfa <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80107e87:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107e8a:	c9                   	leave  
80107e8b:	c3                   	ret    

80107e8c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107e8c:	55                   	push   %ebp
80107e8d:	89 e5                	mov    %esp,%ebp
80107e8f:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107e92:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107e96:	75 0d                	jne    80107ea5 <freevm+0x19>
    panic("freevm: no pgdir");
80107e98:	83 ec 0c             	sub    $0xc,%esp
80107e9b:	68 ab 87 10 80       	push   $0x801087ab
80107ea0:	e8 c1 86 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107ea5:	83 ec 04             	sub    $0x4,%esp
80107ea8:	6a 00                	push   $0x0
80107eaa:	68 00 00 00 80       	push   $0x80000000
80107eaf:	ff 75 08             	pushl  0x8(%ebp)
80107eb2:	e8 18 ff ff ff       	call   80107dcf <deallocuvm>
80107eb7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107eba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ec1:	eb 4f                	jmp    80107f12 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80107ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80107ed0:	01 d0                	add    %edx,%eax
80107ed2:	8b 00                	mov    (%eax),%eax
80107ed4:	83 e0 01             	and    $0x1,%eax
80107ed7:	85 c0                	test   %eax,%eax
80107ed9:	74 33                	je     80107f0e <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80107edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ede:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ee5:	8b 45 08             	mov    0x8(%ebp),%eax
80107ee8:	01 d0                	add    %edx,%eax
80107eea:	8b 00                	mov    (%eax),%eax
80107eec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ef1:	83 ec 0c             	sub    $0xc,%esp
80107ef4:	50                   	push   %eax
80107ef5:	e8 ae f4 ff ff       	call   801073a8 <p2v>
80107efa:	83 c4 10             	add    $0x10,%esp
80107efd:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107f00:	83 ec 0c             	sub    $0xc,%esp
80107f03:	ff 75 f0             	pushl  -0x10(%ebp)
80107f06:	e8 09 ac ff ff       	call   80102b14 <kfree>
80107f0b:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80107f0e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107f12:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107f19:	76 a8                	jbe    80107ec3 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80107f1b:	83 ec 0c             	sub    $0xc,%esp
80107f1e:	ff 75 08             	pushl  0x8(%ebp)
80107f21:	e8 ee ab ff ff       	call   80102b14 <kfree>
80107f26:	83 c4 10             	add    $0x10,%esp
}
80107f29:	90                   	nop
80107f2a:	c9                   	leave  
80107f2b:	c3                   	ret    

80107f2c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107f2c:	55                   	push   %ebp
80107f2d:	89 e5                	mov    %esp,%ebp
80107f2f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107f32:	83 ec 04             	sub    $0x4,%esp
80107f35:	6a 00                	push   $0x0
80107f37:	ff 75 0c             	pushl  0xc(%ebp)
80107f3a:	ff 75 08             	pushl  0x8(%ebp)
80107f3d:	e8 ed f8 ff ff       	call   8010782f <walkpgdir>
80107f42:	83 c4 10             	add    $0x10,%esp
80107f45:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107f48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f4c:	75 0d                	jne    80107f5b <clearpteu+0x2f>
    panic("clearpteu");
80107f4e:	83 ec 0c             	sub    $0xc,%esp
80107f51:	68 bc 87 10 80       	push   $0x801087bc
80107f56:	e8 0b 86 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80107f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5e:	8b 00                	mov    (%eax),%eax
80107f60:	83 e0 fb             	and    $0xfffffffb,%eax
80107f63:	89 c2                	mov    %eax,%edx
80107f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f68:	89 10                	mov    %edx,(%eax)
}
80107f6a:	90                   	nop
80107f6b:	c9                   	leave  
80107f6c:	c3                   	ret    

80107f6d <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107f6d:	55                   	push   %ebp
80107f6e:	89 e5                	mov    %esp,%ebp
80107f70:	53                   	push   %ebx
80107f71:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107f74:	e8 e6 f9 ff ff       	call   8010795f <setupkvm>
80107f79:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f7c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f80:	75 0a                	jne    80107f8c <copyuvm+0x1f>
    return 0;
80107f82:	b8 00 00 00 00       	mov    $0x0,%eax
80107f87:	e9 f8 00 00 00       	jmp    80108084 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
80107f8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f93:	e9 c4 00 00 00       	jmp    8010805c <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9b:	83 ec 04             	sub    $0x4,%esp
80107f9e:	6a 00                	push   $0x0
80107fa0:	50                   	push   %eax
80107fa1:	ff 75 08             	pushl  0x8(%ebp)
80107fa4:	e8 86 f8 ff ff       	call   8010782f <walkpgdir>
80107fa9:	83 c4 10             	add    $0x10,%esp
80107fac:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107faf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fb3:	75 0d                	jne    80107fc2 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80107fb5:	83 ec 0c             	sub    $0xc,%esp
80107fb8:	68 c6 87 10 80       	push   $0x801087c6
80107fbd:	e8 a4 85 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80107fc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fc5:	8b 00                	mov    (%eax),%eax
80107fc7:	83 e0 01             	and    $0x1,%eax
80107fca:	85 c0                	test   %eax,%eax
80107fcc:	75 0d                	jne    80107fdb <copyuvm+0x6e>
      panic("copyuvm: page not present");
80107fce:	83 ec 0c             	sub    $0xc,%esp
80107fd1:	68 e0 87 10 80       	push   $0x801087e0
80107fd6:	e8 8b 85 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80107fdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fde:	8b 00                	mov    (%eax),%eax
80107fe0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fe5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107fe8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107feb:	8b 00                	mov    (%eax),%eax
80107fed:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ff2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107ff5:	e8 b7 ab ff ff       	call   80102bb1 <kalloc>
80107ffa:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107ffd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108001:	74 6a                	je     8010806d <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108003:	83 ec 0c             	sub    $0xc,%esp
80108006:	ff 75 e8             	pushl  -0x18(%ebp)
80108009:	e8 9a f3 ff ff       	call   801073a8 <p2v>
8010800e:	83 c4 10             	add    $0x10,%esp
80108011:	83 ec 04             	sub    $0x4,%esp
80108014:	68 00 10 00 00       	push   $0x1000
80108019:	50                   	push   %eax
8010801a:	ff 75 e0             	pushl  -0x20(%ebp)
8010801d:	e8 c6 ce ff ff       	call   80104ee8 <memmove>
80108022:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108025:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108028:	83 ec 0c             	sub    $0xc,%esp
8010802b:	ff 75 e0             	pushl  -0x20(%ebp)
8010802e:	e8 68 f3 ff ff       	call   8010739b <v2p>
80108033:	83 c4 10             	add    $0x10,%esp
80108036:	89 c2                	mov    %eax,%edx
80108038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803b:	83 ec 0c             	sub    $0xc,%esp
8010803e:	53                   	push   %ebx
8010803f:	52                   	push   %edx
80108040:	68 00 10 00 00       	push   $0x1000
80108045:	50                   	push   %eax
80108046:	ff 75 f0             	pushl  -0x10(%ebp)
80108049:	e8 81 f8 ff ff       	call   801078cf <mappages>
8010804e:	83 c4 20             	add    $0x20,%esp
80108051:	85 c0                	test   %eax,%eax
80108053:	78 1b                	js     80108070 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108055:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010805c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010805f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108062:	0f 82 30 ff ff ff    	jb     80107f98 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108068:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010806b:	eb 17                	jmp    80108084 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010806d:	90                   	nop
8010806e:	eb 01                	jmp    80108071 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80108070:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108071:	83 ec 0c             	sub    $0xc,%esp
80108074:	ff 75 f0             	pushl  -0x10(%ebp)
80108077:	e8 10 fe ff ff       	call   80107e8c <freevm>
8010807c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010807f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108084:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108087:	c9                   	leave  
80108088:	c3                   	ret    

80108089 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108089:	55                   	push   %ebp
8010808a:	89 e5                	mov    %esp,%ebp
8010808c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010808f:	83 ec 04             	sub    $0x4,%esp
80108092:	6a 00                	push   $0x0
80108094:	ff 75 0c             	pushl  0xc(%ebp)
80108097:	ff 75 08             	pushl  0x8(%ebp)
8010809a:	e8 90 f7 ff ff       	call   8010782f <walkpgdir>
8010809f:	83 c4 10             	add    $0x10,%esp
801080a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801080a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a8:	8b 00                	mov    (%eax),%eax
801080aa:	83 e0 01             	and    $0x1,%eax
801080ad:	85 c0                	test   %eax,%eax
801080af:	75 07                	jne    801080b8 <uva2ka+0x2f>
    return 0;
801080b1:	b8 00 00 00 00       	mov    $0x0,%eax
801080b6:	eb 29                	jmp    801080e1 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801080b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080bb:	8b 00                	mov    (%eax),%eax
801080bd:	83 e0 04             	and    $0x4,%eax
801080c0:	85 c0                	test   %eax,%eax
801080c2:	75 07                	jne    801080cb <uva2ka+0x42>
    return 0;
801080c4:	b8 00 00 00 00       	mov    $0x0,%eax
801080c9:	eb 16                	jmp    801080e1 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
801080cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ce:	8b 00                	mov    (%eax),%eax
801080d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080d5:	83 ec 0c             	sub    $0xc,%esp
801080d8:	50                   	push   %eax
801080d9:	e8 ca f2 ff ff       	call   801073a8 <p2v>
801080de:	83 c4 10             	add    $0x10,%esp
}
801080e1:	c9                   	leave  
801080e2:	c3                   	ret    

801080e3 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801080e3:	55                   	push   %ebp
801080e4:	89 e5                	mov    %esp,%ebp
801080e6:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801080e9:	8b 45 10             	mov    0x10(%ebp),%eax
801080ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801080ef:	eb 7f                	jmp    80108170 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801080f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801080f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801080fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080ff:	83 ec 08             	sub    $0x8,%esp
80108102:	50                   	push   %eax
80108103:	ff 75 08             	pushl  0x8(%ebp)
80108106:	e8 7e ff ff ff       	call   80108089 <uva2ka>
8010810b:	83 c4 10             	add    $0x10,%esp
8010810e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108111:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108115:	75 07                	jne    8010811e <copyout+0x3b>
      return -1;
80108117:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010811c:	eb 61                	jmp    8010817f <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010811e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108121:	2b 45 0c             	sub    0xc(%ebp),%eax
80108124:	05 00 10 00 00       	add    $0x1000,%eax
80108129:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010812c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010812f:	3b 45 14             	cmp    0x14(%ebp),%eax
80108132:	76 06                	jbe    8010813a <copyout+0x57>
      n = len;
80108134:	8b 45 14             	mov    0x14(%ebp),%eax
80108137:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010813a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010813d:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108140:	89 c2                	mov    %eax,%edx
80108142:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108145:	01 d0                	add    %edx,%eax
80108147:	83 ec 04             	sub    $0x4,%esp
8010814a:	ff 75 f0             	pushl  -0x10(%ebp)
8010814d:	ff 75 f4             	pushl  -0xc(%ebp)
80108150:	50                   	push   %eax
80108151:	e8 92 cd ff ff       	call   80104ee8 <memmove>
80108156:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108159:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010815c:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010815f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108162:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108165:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108168:	05 00 10 00 00       	add    $0x1000,%eax
8010816d:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108170:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108174:	0f 85 77 ff ff ff    	jne    801080f1 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010817a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010817f:	c9                   	leave  
80108180:	c3                   	ret    
