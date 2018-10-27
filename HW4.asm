
_HW4:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "syscall.h"
#include "traps.h"
#include "memlayout.h"


int main(int argc, char *argv[]) {
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 14             	sub    $0x14,%esp
    int i = getpid();
  11:	e8 c0 03 00 00       	call   3d6 <getpid>
  16:	89 45 f4             	mov    %eax,-0xc(%ebp)
    printf(1,"%d\n",i);
  19:	83 ec 04             	sub    $0x4,%esp
  1c:	ff 75 f4             	pushl  -0xc(%ebp)
  1f:	68 a4 08 00 00       	push   $0x8a4
  24:	6a 01                	push   $0x1
  26:	e8 c2 04 00 00       	call   4ed <printf>
  2b:	83 c4 10             	add    $0x10,%esp
//    return 0;
    int magic = getMagic();
  2e:	e8 c3 03 00 00       	call   3f6 <getMagic>
  33:	89 45 f0             	mov    %eax,-0x10(%ebp)
    printf(1,"current magic number is the following: %d\n",magic);
  36:	83 ec 04             	sub    $0x4,%esp
  39:	ff 75 f0             	pushl  -0x10(%ebp)
  3c:	68 a8 08 00 00       	push   $0x8a8
  41:	6a 01                	push   $0x1
  43:	e8 a5 04 00 00       	call   4ed <printf>
  48:	83 c4 10             	add    $0x10,%esp

   incrementMagic(3);
  4b:	83 ec 0c             	sub    $0xc,%esp
  4e:	6a 03                	push   $0x3
  50:	e8 a9 03 00 00       	call   3fe <incrementMagic>
  55:	83 c4 10             	add    $0x10,%esp
    magic = getMagic();
  58:	e8 99 03 00 00       	call   3f6 <getMagic>
  5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    printf(1,"current magic number is the following: %d\n",magic);
  60:	83 ec 04             	sub    $0x4,%esp
  63:	ff 75 f0             	pushl  -0x10(%ebp)
  66:	68 a8 08 00 00       	push   $0x8a8
  6b:	6a 01                	push   $0x1
  6d:	e8 7b 04 00 00       	call   4ed <printf>
  72:	83 c4 10             	add    $0x10,%esp
    printf(1,"current process name:");
  75:	83 ec 08             	sub    $0x8,%esp
  78:	68 d3 08 00 00       	push   $0x8d3
  7d:	6a 01                	push   $0x1
  7f:	e8 69 04 00 00       	call   4ed <printf>
  84:	83 c4 10             	add    $0x10,%esp

    getCurrentProcessName();
  87:	e8 7a 03 00 00       	call   406 <getCurrentProcessName>

    printf(1,"\n");
  8c:	83 ec 08             	sub    $0x8,%esp
  8f:	68 e9 08 00 00       	push   $0x8e9
  94:	6a 01                	push   $0x1
  96:	e8 52 04 00 00       	call   4ed <printf>
  9b:	83 c4 10             	add    $0x10,%esp

    modifyCurrentProcessName("newName");
  9e:	83 ec 0c             	sub    $0xc,%esp
  a1:	68 eb 08 00 00       	push   $0x8eb
  a6:	e8 63 03 00 00       	call   40e <modifyCurrentProcessName>
  ab:	83 c4 10             	add    $0x10,%esp
    getCurrentProcessName();
  ae:	e8 53 03 00 00       	call   406 <getCurrentProcessName>

    magic = getMagic();
  b3:	e8 3e 03 00 00       	call   3f6 <getMagic>
  b8:	89 45 f0             	mov    %eax,-0x10(%ebp)

    printf(1,"current magic number is the following: %d\n",magic);
  bb:	83 ec 04             	sub    $0x4,%esp
  be:	ff 75 f0             	pushl  -0x10(%ebp)
  c1:	68 a8 08 00 00       	push   $0x8a8
  c6:	6a 01                	push   $0x1
  c8:	e8 20 04 00 00       	call   4ed <printf>
  cd:	83 c4 10             	add    $0x10,%esp

    incrementMagic(3);
  d0:	83 ec 0c             	sub    $0xc,%esp
  d3:	6a 03                	push   $0x3
  d5:	e8 24 03 00 00       	call   3fe <incrementMagic>
  da:	83 c4 10             	add    $0x10,%esp

    magic = getMagic();
  dd:	e8 14 03 00 00       	call   3f6 <getMagic>
  e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    printf(1,"current magic number is the following %d\n",magic);
  e5:	83 ec 04             	sub    $0x4,%esp
  e8:	ff 75 f0             	pushl  -0x10(%ebp)
  eb:	68 f4 08 00 00       	push   $0x8f4
  f0:	6a 01                	push   $0x1
  f2:	e8 f6 03 00 00       	call   4ed <printf>
  f7:	83 c4 10             	add    $0x10,%esp

    exit();
  fa:	e8 57 02 00 00       	call   356 <exit>

000000ff <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  ff:	55                   	push   %ebp
 100:	89 e5                	mov    %esp,%ebp
 102:	57                   	push   %edi
 103:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 104:	8b 4d 08             	mov    0x8(%ebp),%ecx
 107:	8b 55 10             	mov    0x10(%ebp),%edx
 10a:	8b 45 0c             	mov    0xc(%ebp),%eax
 10d:	89 cb                	mov    %ecx,%ebx
 10f:	89 df                	mov    %ebx,%edi
 111:	89 d1                	mov    %edx,%ecx
 113:	fc                   	cld    
 114:	f3 aa                	rep stos %al,%es:(%edi)
 116:	89 ca                	mov    %ecx,%edx
 118:	89 fb                	mov    %edi,%ebx
 11a:	89 5d 08             	mov    %ebx,0x8(%ebp)
 11d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 120:	90                   	nop
 121:	5b                   	pop    %ebx
 122:	5f                   	pop    %edi
 123:	5d                   	pop    %ebp
 124:	c3                   	ret    

00000125 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 125:	55                   	push   %ebp
 126:	89 e5                	mov    %esp,%ebp
 128:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 12b:	8b 45 08             	mov    0x8(%ebp),%eax
 12e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 131:	90                   	nop
 132:	8b 45 08             	mov    0x8(%ebp),%eax
 135:	8d 50 01             	lea    0x1(%eax),%edx
 138:	89 55 08             	mov    %edx,0x8(%ebp)
 13b:	8b 55 0c             	mov    0xc(%ebp),%edx
 13e:	8d 4a 01             	lea    0x1(%edx),%ecx
 141:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 144:	0f b6 12             	movzbl (%edx),%edx
 147:	88 10                	mov    %dl,(%eax)
 149:	0f b6 00             	movzbl (%eax),%eax
 14c:	84 c0                	test   %al,%al
 14e:	75 e2                	jne    132 <strcpy+0xd>
    ;
  return os;
 150:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 153:	c9                   	leave  
 154:	c3                   	ret    

00000155 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 155:	55                   	push   %ebp
 156:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 158:	eb 08                	jmp    162 <strcmp+0xd>
    p++, q++;
 15a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 15e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 162:	8b 45 08             	mov    0x8(%ebp),%eax
 165:	0f b6 00             	movzbl (%eax),%eax
 168:	84 c0                	test   %al,%al
 16a:	74 10                	je     17c <strcmp+0x27>
 16c:	8b 45 08             	mov    0x8(%ebp),%eax
 16f:	0f b6 10             	movzbl (%eax),%edx
 172:	8b 45 0c             	mov    0xc(%ebp),%eax
 175:	0f b6 00             	movzbl (%eax),%eax
 178:	38 c2                	cmp    %al,%dl
 17a:	74 de                	je     15a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 17c:	8b 45 08             	mov    0x8(%ebp),%eax
 17f:	0f b6 00             	movzbl (%eax),%eax
 182:	0f b6 d0             	movzbl %al,%edx
 185:	8b 45 0c             	mov    0xc(%ebp),%eax
 188:	0f b6 00             	movzbl (%eax),%eax
 18b:	0f b6 c0             	movzbl %al,%eax
 18e:	29 c2                	sub    %eax,%edx
 190:	89 d0                	mov    %edx,%eax
}
 192:	5d                   	pop    %ebp
 193:	c3                   	ret    

00000194 <strlen>:

uint
strlen(char *s)
{
 194:	55                   	push   %ebp
 195:	89 e5                	mov    %esp,%ebp
 197:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 19a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1a1:	eb 04                	jmp    1a7 <strlen+0x13>
 1a3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1a7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1aa:	8b 45 08             	mov    0x8(%ebp),%eax
 1ad:	01 d0                	add    %edx,%eax
 1af:	0f b6 00             	movzbl (%eax),%eax
 1b2:	84 c0                	test   %al,%al
 1b4:	75 ed                	jne    1a3 <strlen+0xf>
    ;
  return n;
 1b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1b9:	c9                   	leave  
 1ba:	c3                   	ret    

000001bb <memset>:

void*
memset(void *dst, int c, uint n)
{
 1bb:	55                   	push   %ebp
 1bc:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1be:	8b 45 10             	mov    0x10(%ebp),%eax
 1c1:	50                   	push   %eax
 1c2:	ff 75 0c             	pushl  0xc(%ebp)
 1c5:	ff 75 08             	pushl  0x8(%ebp)
 1c8:	e8 32 ff ff ff       	call   ff <stosb>
 1cd:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1d0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1d3:	c9                   	leave  
 1d4:	c3                   	ret    

000001d5 <strchr>:

char*
strchr(const char *s, char c)
{
 1d5:	55                   	push   %ebp
 1d6:	89 e5                	mov    %esp,%ebp
 1d8:	83 ec 04             	sub    $0x4,%esp
 1db:	8b 45 0c             	mov    0xc(%ebp),%eax
 1de:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1e1:	eb 14                	jmp    1f7 <strchr+0x22>
    if(*s == c)
 1e3:	8b 45 08             	mov    0x8(%ebp),%eax
 1e6:	0f b6 00             	movzbl (%eax),%eax
 1e9:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1ec:	75 05                	jne    1f3 <strchr+0x1e>
      return (char*)s;
 1ee:	8b 45 08             	mov    0x8(%ebp),%eax
 1f1:	eb 13                	jmp    206 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1f7:	8b 45 08             	mov    0x8(%ebp),%eax
 1fa:	0f b6 00             	movzbl (%eax),%eax
 1fd:	84 c0                	test   %al,%al
 1ff:	75 e2                	jne    1e3 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 201:	b8 00 00 00 00       	mov    $0x0,%eax
}
 206:	c9                   	leave  
 207:	c3                   	ret    

00000208 <gets>:

char*
gets(char *buf, int max)
{
 208:	55                   	push   %ebp
 209:	89 e5                	mov    %esp,%ebp
 20b:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 215:	eb 42                	jmp    259 <gets+0x51>
    cc = read(0, &c, 1);
 217:	83 ec 04             	sub    $0x4,%esp
 21a:	6a 01                	push   $0x1
 21c:	8d 45 ef             	lea    -0x11(%ebp),%eax
 21f:	50                   	push   %eax
 220:	6a 00                	push   $0x0
 222:	e8 47 01 00 00       	call   36e <read>
 227:	83 c4 10             	add    $0x10,%esp
 22a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 22d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 231:	7e 33                	jle    266 <gets+0x5e>
      break;
    buf[i++] = c;
 233:	8b 45 f4             	mov    -0xc(%ebp),%eax
 236:	8d 50 01             	lea    0x1(%eax),%edx
 239:	89 55 f4             	mov    %edx,-0xc(%ebp)
 23c:	89 c2                	mov    %eax,%edx
 23e:	8b 45 08             	mov    0x8(%ebp),%eax
 241:	01 c2                	add    %eax,%edx
 243:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 247:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 249:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 24d:	3c 0a                	cmp    $0xa,%al
 24f:	74 16                	je     267 <gets+0x5f>
 251:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 255:	3c 0d                	cmp    $0xd,%al
 257:	74 0e                	je     267 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 259:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25c:	83 c0 01             	add    $0x1,%eax
 25f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 262:	7c b3                	jl     217 <gets+0xf>
 264:	eb 01                	jmp    267 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 266:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 267:	8b 55 f4             	mov    -0xc(%ebp),%edx
 26a:	8b 45 08             	mov    0x8(%ebp),%eax
 26d:	01 d0                	add    %edx,%eax
 26f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 272:	8b 45 08             	mov    0x8(%ebp),%eax
}
 275:	c9                   	leave  
 276:	c3                   	ret    

00000277 <stat>:

int
stat(char *n, struct stat *st)
{
 277:	55                   	push   %ebp
 278:	89 e5                	mov    %esp,%ebp
 27a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27d:	83 ec 08             	sub    $0x8,%esp
 280:	6a 00                	push   $0x0
 282:	ff 75 08             	pushl  0x8(%ebp)
 285:	e8 0c 01 00 00       	call   396 <open>
 28a:	83 c4 10             	add    $0x10,%esp
 28d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 290:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 294:	79 07                	jns    29d <stat+0x26>
    return -1;
 296:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 29b:	eb 25                	jmp    2c2 <stat+0x4b>
  r = fstat(fd, st);
 29d:	83 ec 08             	sub    $0x8,%esp
 2a0:	ff 75 0c             	pushl  0xc(%ebp)
 2a3:	ff 75 f4             	pushl  -0xc(%ebp)
 2a6:	e8 03 01 00 00       	call   3ae <fstat>
 2ab:	83 c4 10             	add    $0x10,%esp
 2ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2b1:	83 ec 0c             	sub    $0xc,%esp
 2b4:	ff 75 f4             	pushl  -0xc(%ebp)
 2b7:	e8 c2 00 00 00       	call   37e <close>
 2bc:	83 c4 10             	add    $0x10,%esp
  return r;
 2bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2c2:	c9                   	leave  
 2c3:	c3                   	ret    

000002c4 <atoi>:

int
atoi(const char *s)
{
 2c4:	55                   	push   %ebp
 2c5:	89 e5                	mov    %esp,%ebp
 2c7:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2ca:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2d1:	eb 25                	jmp    2f8 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2d3:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2d6:	89 d0                	mov    %edx,%eax
 2d8:	c1 e0 02             	shl    $0x2,%eax
 2db:	01 d0                	add    %edx,%eax
 2dd:	01 c0                	add    %eax,%eax
 2df:	89 c1                	mov    %eax,%ecx
 2e1:	8b 45 08             	mov    0x8(%ebp),%eax
 2e4:	8d 50 01             	lea    0x1(%eax),%edx
 2e7:	89 55 08             	mov    %edx,0x8(%ebp)
 2ea:	0f b6 00             	movzbl (%eax),%eax
 2ed:	0f be c0             	movsbl %al,%eax
 2f0:	01 c8                	add    %ecx,%eax
 2f2:	83 e8 30             	sub    $0x30,%eax
 2f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f8:	8b 45 08             	mov    0x8(%ebp),%eax
 2fb:	0f b6 00             	movzbl (%eax),%eax
 2fe:	3c 2f                	cmp    $0x2f,%al
 300:	7e 0a                	jle    30c <atoi+0x48>
 302:	8b 45 08             	mov    0x8(%ebp),%eax
 305:	0f b6 00             	movzbl (%eax),%eax
 308:	3c 39                	cmp    $0x39,%al
 30a:	7e c7                	jle    2d3 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 30c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 30f:	c9                   	leave  
 310:	c3                   	ret    

00000311 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 311:	55                   	push   %ebp
 312:	89 e5                	mov    %esp,%ebp
 314:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 317:	8b 45 08             	mov    0x8(%ebp),%eax
 31a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 31d:	8b 45 0c             	mov    0xc(%ebp),%eax
 320:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 323:	eb 17                	jmp    33c <memmove+0x2b>
    *dst++ = *src++;
 325:	8b 45 fc             	mov    -0x4(%ebp),%eax
 328:	8d 50 01             	lea    0x1(%eax),%edx
 32b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 32e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 331:	8d 4a 01             	lea    0x1(%edx),%ecx
 334:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 337:	0f b6 12             	movzbl (%edx),%edx
 33a:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 33c:	8b 45 10             	mov    0x10(%ebp),%eax
 33f:	8d 50 ff             	lea    -0x1(%eax),%edx
 342:	89 55 10             	mov    %edx,0x10(%ebp)
 345:	85 c0                	test   %eax,%eax
 347:	7f dc                	jg     325 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 349:	8b 45 08             	mov    0x8(%ebp),%eax
}
 34c:	c9                   	leave  
 34d:	c3                   	ret    

0000034e <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 34e:	b8 01 00 00 00       	mov    $0x1,%eax
 353:	cd 40                	int    $0x40
 355:	c3                   	ret    

00000356 <exit>:
SYSCALL(exit)
 356:	b8 02 00 00 00       	mov    $0x2,%eax
 35b:	cd 40                	int    $0x40
 35d:	c3                   	ret    

0000035e <wait>:
SYSCALL(wait)
 35e:	b8 03 00 00 00       	mov    $0x3,%eax
 363:	cd 40                	int    $0x40
 365:	c3                   	ret    

00000366 <pipe>:
SYSCALL(pipe)
 366:	b8 04 00 00 00       	mov    $0x4,%eax
 36b:	cd 40                	int    $0x40
 36d:	c3                   	ret    

0000036e <read>:
SYSCALL(read)
 36e:	b8 05 00 00 00       	mov    $0x5,%eax
 373:	cd 40                	int    $0x40
 375:	c3                   	ret    

00000376 <write>:
SYSCALL(write)
 376:	b8 10 00 00 00       	mov    $0x10,%eax
 37b:	cd 40                	int    $0x40
 37d:	c3                   	ret    

0000037e <close>:
SYSCALL(close)
 37e:	b8 15 00 00 00       	mov    $0x15,%eax
 383:	cd 40                	int    $0x40
 385:	c3                   	ret    

00000386 <kill>:
SYSCALL(kill)
 386:	b8 06 00 00 00       	mov    $0x6,%eax
 38b:	cd 40                	int    $0x40
 38d:	c3                   	ret    

0000038e <exec>:
SYSCALL(exec)
 38e:	b8 07 00 00 00       	mov    $0x7,%eax
 393:	cd 40                	int    $0x40
 395:	c3                   	ret    

00000396 <open>:
SYSCALL(open)
 396:	b8 0f 00 00 00       	mov    $0xf,%eax
 39b:	cd 40                	int    $0x40
 39d:	c3                   	ret    

0000039e <mknod>:
SYSCALL(mknod)
 39e:	b8 11 00 00 00       	mov    $0x11,%eax
 3a3:	cd 40                	int    $0x40
 3a5:	c3                   	ret    

000003a6 <unlink>:
SYSCALL(unlink)
 3a6:	b8 12 00 00 00       	mov    $0x12,%eax
 3ab:	cd 40                	int    $0x40
 3ad:	c3                   	ret    

000003ae <fstat>:
SYSCALL(fstat)
 3ae:	b8 08 00 00 00       	mov    $0x8,%eax
 3b3:	cd 40                	int    $0x40
 3b5:	c3                   	ret    

000003b6 <link>:
SYSCALL(link)
 3b6:	b8 13 00 00 00       	mov    $0x13,%eax
 3bb:	cd 40                	int    $0x40
 3bd:	c3                   	ret    

000003be <mkdir>:
SYSCALL(mkdir)
 3be:	b8 14 00 00 00       	mov    $0x14,%eax
 3c3:	cd 40                	int    $0x40
 3c5:	c3                   	ret    

000003c6 <chdir>:
SYSCALL(chdir)
 3c6:	b8 09 00 00 00       	mov    $0x9,%eax
 3cb:	cd 40                	int    $0x40
 3cd:	c3                   	ret    

000003ce <dup>:
SYSCALL(dup)
 3ce:	b8 0a 00 00 00       	mov    $0xa,%eax
 3d3:	cd 40                	int    $0x40
 3d5:	c3                   	ret    

000003d6 <getpid>:
SYSCALL(getpid)
 3d6:	b8 0b 00 00 00       	mov    $0xb,%eax
 3db:	cd 40                	int    $0x40
 3dd:	c3                   	ret    

000003de <sbrk>:
SYSCALL(sbrk)
 3de:	b8 0c 00 00 00       	mov    $0xc,%eax
 3e3:	cd 40                	int    $0x40
 3e5:	c3                   	ret    

000003e6 <sleep>:
SYSCALL(sleep)
 3e6:	b8 0d 00 00 00       	mov    $0xd,%eax
 3eb:	cd 40                	int    $0x40
 3ed:	c3                   	ret    

000003ee <uptime>:
SYSCALL(uptime)
 3ee:	b8 0e 00 00 00       	mov    $0xe,%eax
 3f3:	cd 40                	int    $0x40
 3f5:	c3                   	ret    

000003f6 <getMagic>:
SYSCALL(getMagic)
 3f6:	b8 17 00 00 00       	mov    $0x17,%eax
 3fb:	cd 40                	int    $0x40
 3fd:	c3                   	ret    

000003fe <incrementMagic>:
SYSCALL(incrementMagic)
 3fe:	b8 16 00 00 00       	mov    $0x16,%eax
 403:	cd 40                	int    $0x40
 405:	c3                   	ret    

00000406 <getCurrentProcessName>:
SYSCALL(getCurrentProcessName)
 406:	b8 18 00 00 00       	mov    $0x18,%eax
 40b:	cd 40                	int    $0x40
 40d:	c3                   	ret    

0000040e <modifyCurrentProcessName>:
SYSCALL(modifyCurrentProcessName)
 40e:	b8 19 00 00 00       	mov    $0x19,%eax
 413:	cd 40                	int    $0x40
 415:	c3                   	ret    

00000416 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 416:	55                   	push   %ebp
 417:	89 e5                	mov    %esp,%ebp
 419:	83 ec 18             	sub    $0x18,%esp
 41c:	8b 45 0c             	mov    0xc(%ebp),%eax
 41f:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 422:	83 ec 04             	sub    $0x4,%esp
 425:	6a 01                	push   $0x1
 427:	8d 45 f4             	lea    -0xc(%ebp),%eax
 42a:	50                   	push   %eax
 42b:	ff 75 08             	pushl  0x8(%ebp)
 42e:	e8 43 ff ff ff       	call   376 <write>
 433:	83 c4 10             	add    $0x10,%esp
}
 436:	90                   	nop
 437:	c9                   	leave  
 438:	c3                   	ret    

00000439 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 439:	55                   	push   %ebp
 43a:	89 e5                	mov    %esp,%ebp
 43c:	53                   	push   %ebx
 43d:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 440:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 447:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 44b:	74 17                	je     464 <printint+0x2b>
 44d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 451:	79 11                	jns    464 <printint+0x2b>
    neg = 1;
 453:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 45a:	8b 45 0c             	mov    0xc(%ebp),%eax
 45d:	f7 d8                	neg    %eax
 45f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 462:	eb 06                	jmp    46a <printint+0x31>
  } else {
    x = xx;
 464:	8b 45 0c             	mov    0xc(%ebp),%eax
 467:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 46a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 471:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 474:	8d 41 01             	lea    0x1(%ecx),%eax
 477:	89 45 f4             	mov    %eax,-0xc(%ebp)
 47a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 47d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 480:	ba 00 00 00 00       	mov    $0x0,%edx
 485:	f7 f3                	div    %ebx
 487:	89 d0                	mov    %edx,%eax
 489:	0f b6 80 70 0b 00 00 	movzbl 0xb70(%eax),%eax
 490:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 494:	8b 5d 10             	mov    0x10(%ebp),%ebx
 497:	8b 45 ec             	mov    -0x14(%ebp),%eax
 49a:	ba 00 00 00 00       	mov    $0x0,%edx
 49f:	f7 f3                	div    %ebx
 4a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4a8:	75 c7                	jne    471 <printint+0x38>
  if(neg)
 4aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4ae:	74 2d                	je     4dd <printint+0xa4>
    buf[i++] = '-';
 4b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b3:	8d 50 01             	lea    0x1(%eax),%edx
 4b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4b9:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4be:	eb 1d                	jmp    4dd <printint+0xa4>
    putc(fd, buf[i]);
 4c0:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c6:	01 d0                	add    %edx,%eax
 4c8:	0f b6 00             	movzbl (%eax),%eax
 4cb:	0f be c0             	movsbl %al,%eax
 4ce:	83 ec 08             	sub    $0x8,%esp
 4d1:	50                   	push   %eax
 4d2:	ff 75 08             	pushl  0x8(%ebp)
 4d5:	e8 3c ff ff ff       	call   416 <putc>
 4da:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4dd:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4e5:	79 d9                	jns    4c0 <printint+0x87>
    putc(fd, buf[i]);
}
 4e7:	90                   	nop
 4e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 4eb:	c9                   	leave  
 4ec:	c3                   	ret    

000004ed <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4ed:	55                   	push   %ebp
 4ee:	89 e5                	mov    %esp,%ebp
 4f0:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4f3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4fa:	8d 45 0c             	lea    0xc(%ebp),%eax
 4fd:	83 c0 04             	add    $0x4,%eax
 500:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 503:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 50a:	e9 59 01 00 00       	jmp    668 <printf+0x17b>
    c = fmt[i] & 0xff;
 50f:	8b 55 0c             	mov    0xc(%ebp),%edx
 512:	8b 45 f0             	mov    -0x10(%ebp),%eax
 515:	01 d0                	add    %edx,%eax
 517:	0f b6 00             	movzbl (%eax),%eax
 51a:	0f be c0             	movsbl %al,%eax
 51d:	25 ff 00 00 00       	and    $0xff,%eax
 522:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 525:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 529:	75 2c                	jne    557 <printf+0x6a>
      if(c == '%'){
 52b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 52f:	75 0c                	jne    53d <printf+0x50>
        state = '%';
 531:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 538:	e9 27 01 00 00       	jmp    664 <printf+0x177>
      } else {
        putc(fd, c);
 53d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 540:	0f be c0             	movsbl %al,%eax
 543:	83 ec 08             	sub    $0x8,%esp
 546:	50                   	push   %eax
 547:	ff 75 08             	pushl  0x8(%ebp)
 54a:	e8 c7 fe ff ff       	call   416 <putc>
 54f:	83 c4 10             	add    $0x10,%esp
 552:	e9 0d 01 00 00       	jmp    664 <printf+0x177>
      }
    } else if(state == '%'){
 557:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 55b:	0f 85 03 01 00 00    	jne    664 <printf+0x177>
      if(c == 'd'){
 561:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 565:	75 1e                	jne    585 <printf+0x98>
        printint(fd, *ap, 10, 1);
 567:	8b 45 e8             	mov    -0x18(%ebp),%eax
 56a:	8b 00                	mov    (%eax),%eax
 56c:	6a 01                	push   $0x1
 56e:	6a 0a                	push   $0xa
 570:	50                   	push   %eax
 571:	ff 75 08             	pushl  0x8(%ebp)
 574:	e8 c0 fe ff ff       	call   439 <printint>
 579:	83 c4 10             	add    $0x10,%esp
        ap++;
 57c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 580:	e9 d8 00 00 00       	jmp    65d <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 585:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 589:	74 06                	je     591 <printf+0xa4>
 58b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 58f:	75 1e                	jne    5af <printf+0xc2>
        printint(fd, *ap, 16, 0);
 591:	8b 45 e8             	mov    -0x18(%ebp),%eax
 594:	8b 00                	mov    (%eax),%eax
 596:	6a 00                	push   $0x0
 598:	6a 10                	push   $0x10
 59a:	50                   	push   %eax
 59b:	ff 75 08             	pushl  0x8(%ebp)
 59e:	e8 96 fe ff ff       	call   439 <printint>
 5a3:	83 c4 10             	add    $0x10,%esp
        ap++;
 5a6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5aa:	e9 ae 00 00 00       	jmp    65d <printf+0x170>
      } else if(c == 's'){
 5af:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5b3:	75 43                	jne    5f8 <printf+0x10b>
        s = (char*)*ap;
 5b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b8:	8b 00                	mov    (%eax),%eax
 5ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5bd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5c5:	75 25                	jne    5ec <printf+0xff>
          s = "(null)";
 5c7:	c7 45 f4 1e 09 00 00 	movl   $0x91e,-0xc(%ebp)
        while(*s != 0){
 5ce:	eb 1c                	jmp    5ec <printf+0xff>
          putc(fd, *s);
 5d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d3:	0f b6 00             	movzbl (%eax),%eax
 5d6:	0f be c0             	movsbl %al,%eax
 5d9:	83 ec 08             	sub    $0x8,%esp
 5dc:	50                   	push   %eax
 5dd:	ff 75 08             	pushl  0x8(%ebp)
 5e0:	e8 31 fe ff ff       	call   416 <putc>
 5e5:	83 c4 10             	add    $0x10,%esp
          s++;
 5e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ef:	0f b6 00             	movzbl (%eax),%eax
 5f2:	84 c0                	test   %al,%al
 5f4:	75 da                	jne    5d0 <printf+0xe3>
 5f6:	eb 65                	jmp    65d <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5f8:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5fc:	75 1d                	jne    61b <printf+0x12e>
        putc(fd, *ap);
 5fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
 601:	8b 00                	mov    (%eax),%eax
 603:	0f be c0             	movsbl %al,%eax
 606:	83 ec 08             	sub    $0x8,%esp
 609:	50                   	push   %eax
 60a:	ff 75 08             	pushl  0x8(%ebp)
 60d:	e8 04 fe ff ff       	call   416 <putc>
 612:	83 c4 10             	add    $0x10,%esp
        ap++;
 615:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 619:	eb 42                	jmp    65d <printf+0x170>
      } else if(c == '%'){
 61b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 61f:	75 17                	jne    638 <printf+0x14b>
        putc(fd, c);
 621:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 624:	0f be c0             	movsbl %al,%eax
 627:	83 ec 08             	sub    $0x8,%esp
 62a:	50                   	push   %eax
 62b:	ff 75 08             	pushl  0x8(%ebp)
 62e:	e8 e3 fd ff ff       	call   416 <putc>
 633:	83 c4 10             	add    $0x10,%esp
 636:	eb 25                	jmp    65d <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 638:	83 ec 08             	sub    $0x8,%esp
 63b:	6a 25                	push   $0x25
 63d:	ff 75 08             	pushl  0x8(%ebp)
 640:	e8 d1 fd ff ff       	call   416 <putc>
 645:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 648:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 64b:	0f be c0             	movsbl %al,%eax
 64e:	83 ec 08             	sub    $0x8,%esp
 651:	50                   	push   %eax
 652:	ff 75 08             	pushl  0x8(%ebp)
 655:	e8 bc fd ff ff       	call   416 <putc>
 65a:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 65d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 664:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 668:	8b 55 0c             	mov    0xc(%ebp),%edx
 66b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 66e:	01 d0                	add    %edx,%eax
 670:	0f b6 00             	movzbl (%eax),%eax
 673:	84 c0                	test   %al,%al
 675:	0f 85 94 fe ff ff    	jne    50f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 67b:	90                   	nop
 67c:	c9                   	leave  
 67d:	c3                   	ret    

0000067e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 67e:	55                   	push   %ebp
 67f:	89 e5                	mov    %esp,%ebp
 681:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 684:	8b 45 08             	mov    0x8(%ebp),%eax
 687:	83 e8 08             	sub    $0x8,%eax
 68a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 68d:	a1 8c 0b 00 00       	mov    0xb8c,%eax
 692:	89 45 fc             	mov    %eax,-0x4(%ebp)
 695:	eb 24                	jmp    6bb <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 697:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69a:	8b 00                	mov    (%eax),%eax
 69c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 69f:	77 12                	ja     6b3 <free+0x35>
 6a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6a7:	77 24                	ja     6cd <free+0x4f>
 6a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ac:	8b 00                	mov    (%eax),%eax
 6ae:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6b1:	77 1a                	ja     6cd <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b6:	8b 00                	mov    (%eax),%eax
 6b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6be:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6c1:	76 d4                	jbe    697 <free+0x19>
 6c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c6:	8b 00                	mov    (%eax),%eax
 6c8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6cb:	76 ca                	jbe    697 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d0:	8b 40 04             	mov    0x4(%eax),%eax
 6d3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6dd:	01 c2                	add    %eax,%edx
 6df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e2:	8b 00                	mov    (%eax),%eax
 6e4:	39 c2                	cmp    %eax,%edx
 6e6:	75 24                	jne    70c <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6eb:	8b 50 04             	mov    0x4(%eax),%edx
 6ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f1:	8b 00                	mov    (%eax),%eax
 6f3:	8b 40 04             	mov    0x4(%eax),%eax
 6f6:	01 c2                	add    %eax,%edx
 6f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fb:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 701:	8b 00                	mov    (%eax),%eax
 703:	8b 10                	mov    (%eax),%edx
 705:	8b 45 f8             	mov    -0x8(%ebp),%eax
 708:	89 10                	mov    %edx,(%eax)
 70a:	eb 0a                	jmp    716 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 70c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70f:	8b 10                	mov    (%eax),%edx
 711:	8b 45 f8             	mov    -0x8(%ebp),%eax
 714:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 716:	8b 45 fc             	mov    -0x4(%ebp),%eax
 719:	8b 40 04             	mov    0x4(%eax),%eax
 71c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 723:	8b 45 fc             	mov    -0x4(%ebp),%eax
 726:	01 d0                	add    %edx,%eax
 728:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 72b:	75 20                	jne    74d <free+0xcf>
    p->s.size += bp->s.size;
 72d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 730:	8b 50 04             	mov    0x4(%eax),%edx
 733:	8b 45 f8             	mov    -0x8(%ebp),%eax
 736:	8b 40 04             	mov    0x4(%eax),%eax
 739:	01 c2                	add    %eax,%edx
 73b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 741:	8b 45 f8             	mov    -0x8(%ebp),%eax
 744:	8b 10                	mov    (%eax),%edx
 746:	8b 45 fc             	mov    -0x4(%ebp),%eax
 749:	89 10                	mov    %edx,(%eax)
 74b:	eb 08                	jmp    755 <free+0xd7>
  } else
    p->s.ptr = bp;
 74d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 750:	8b 55 f8             	mov    -0x8(%ebp),%edx
 753:	89 10                	mov    %edx,(%eax)
  freep = p;
 755:	8b 45 fc             	mov    -0x4(%ebp),%eax
 758:	a3 8c 0b 00 00       	mov    %eax,0xb8c
}
 75d:	90                   	nop
 75e:	c9                   	leave  
 75f:	c3                   	ret    

00000760 <morecore>:

static Header*
morecore(uint nu)
{
 760:	55                   	push   %ebp
 761:	89 e5                	mov    %esp,%ebp
 763:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 766:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 76d:	77 07                	ja     776 <morecore+0x16>
    nu = 4096;
 76f:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 776:	8b 45 08             	mov    0x8(%ebp),%eax
 779:	c1 e0 03             	shl    $0x3,%eax
 77c:	83 ec 0c             	sub    $0xc,%esp
 77f:	50                   	push   %eax
 780:	e8 59 fc ff ff       	call   3de <sbrk>
 785:	83 c4 10             	add    $0x10,%esp
 788:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 78b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 78f:	75 07                	jne    798 <morecore+0x38>
    return 0;
 791:	b8 00 00 00 00       	mov    $0x0,%eax
 796:	eb 26                	jmp    7be <morecore+0x5e>
  hp = (Header*)p;
 798:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 79e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a1:	8b 55 08             	mov    0x8(%ebp),%edx
 7a4:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7aa:	83 c0 08             	add    $0x8,%eax
 7ad:	83 ec 0c             	sub    $0xc,%esp
 7b0:	50                   	push   %eax
 7b1:	e8 c8 fe ff ff       	call   67e <free>
 7b6:	83 c4 10             	add    $0x10,%esp
  return freep;
 7b9:	a1 8c 0b 00 00       	mov    0xb8c,%eax
}
 7be:	c9                   	leave  
 7bf:	c3                   	ret    

000007c0 <malloc>:

void*
malloc(uint nbytes)
{
 7c0:	55                   	push   %ebp
 7c1:	89 e5                	mov    %esp,%ebp
 7c3:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c6:	8b 45 08             	mov    0x8(%ebp),%eax
 7c9:	83 c0 07             	add    $0x7,%eax
 7cc:	c1 e8 03             	shr    $0x3,%eax
 7cf:	83 c0 01             	add    $0x1,%eax
 7d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7d5:	a1 8c 0b 00 00       	mov    0xb8c,%eax
 7da:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7e1:	75 23                	jne    806 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7e3:	c7 45 f0 84 0b 00 00 	movl   $0xb84,-0x10(%ebp)
 7ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ed:	a3 8c 0b 00 00       	mov    %eax,0xb8c
 7f2:	a1 8c 0b 00 00       	mov    0xb8c,%eax
 7f7:	a3 84 0b 00 00       	mov    %eax,0xb84
    base.s.size = 0;
 7fc:	c7 05 88 0b 00 00 00 	movl   $0x0,0xb88
 803:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 806:	8b 45 f0             	mov    -0x10(%ebp),%eax
 809:	8b 00                	mov    (%eax),%eax
 80b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 80e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 811:	8b 40 04             	mov    0x4(%eax),%eax
 814:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 817:	72 4d                	jb     866 <malloc+0xa6>
      if(p->s.size == nunits)
 819:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81c:	8b 40 04             	mov    0x4(%eax),%eax
 81f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 822:	75 0c                	jne    830 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 824:	8b 45 f4             	mov    -0xc(%ebp),%eax
 827:	8b 10                	mov    (%eax),%edx
 829:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82c:	89 10                	mov    %edx,(%eax)
 82e:	eb 26                	jmp    856 <malloc+0x96>
      else {
        p->s.size -= nunits;
 830:	8b 45 f4             	mov    -0xc(%ebp),%eax
 833:	8b 40 04             	mov    0x4(%eax),%eax
 836:	2b 45 ec             	sub    -0x14(%ebp),%eax
 839:	89 c2                	mov    %eax,%edx
 83b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 841:	8b 45 f4             	mov    -0xc(%ebp),%eax
 844:	8b 40 04             	mov    0x4(%eax),%eax
 847:	c1 e0 03             	shl    $0x3,%eax
 84a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 84d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 850:	8b 55 ec             	mov    -0x14(%ebp),%edx
 853:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 856:	8b 45 f0             	mov    -0x10(%ebp),%eax
 859:	a3 8c 0b 00 00       	mov    %eax,0xb8c
      return (void*)(p + 1);
 85e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 861:	83 c0 08             	add    $0x8,%eax
 864:	eb 3b                	jmp    8a1 <malloc+0xe1>
    }
    if(p == freep)
 866:	a1 8c 0b 00 00       	mov    0xb8c,%eax
 86b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 86e:	75 1e                	jne    88e <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 870:	83 ec 0c             	sub    $0xc,%esp
 873:	ff 75 ec             	pushl  -0x14(%ebp)
 876:	e8 e5 fe ff ff       	call   760 <morecore>
 87b:	83 c4 10             	add    $0x10,%esp
 87e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 881:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 885:	75 07                	jne    88e <malloc+0xce>
        return 0;
 887:	b8 00 00 00 00       	mov    $0x0,%eax
 88c:	eb 13                	jmp    8a1 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 891:	89 45 f0             	mov    %eax,-0x10(%ebp)
 894:	8b 45 f4             	mov    -0xc(%ebp),%eax
 897:	8b 00                	mov    (%eax),%eax
 899:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 89c:	e9 6d ff ff ff       	jmp    80e <malloc+0x4e>
}
 8a1:	c9                   	leave  
 8a2:	c3                   	ret    
