# Video codecs

**Big picture:** a video codec compresses frames. Delivery codecs target small files a player can decode. Editing codecs stay large so cuts and color work stay easy.

Related: [Codec](codec.md) · [Audio codecs](audio-codecs.md)

## Delivery

| Codec | Also called | Where it shows up |
|---|---|---|
| H.264 | AVC | Phones, browsers, cameras, Blu-ray, most streams. The usual default. |
| H.265 | HEVC | 4K streaming, Apple devices, newer cameras. More efficient than H.264 at a similar picture. Patent licenses apply. |
| VP9 | | YouTube and WebM. Royalty-free. |
| AV1 | | YouTube, Netflix, current browsers. Royalty-free, and usually smaller than VP9 or HEVC. Encoding is slower. |
| MPEG-2 | H.262 | DVD and older broadcast television. |
| H.266 | VVC | More efficient than HEVC. Still uncommon. Licensed. |

## Editing

Apple ProRes and Avid DNxHR are for editing. They use a high bitrate so frames are cheap to read in any order. JPEG 2000 is the picture codec in digital cinema packages.

## Two names

H.262, H.264, H.265, and H.266 each have a second name. The ITU-T, the telecom standards body, numbers them in the H.26x series. ISO/IEC MPEG publishes the same text under a title: MPEG-2 Video, AVC, HEVC, and VVC. A joint committee wrote each spec once. Both catalogs printed it.

| ITU-T number | MPEG name | MPEG document |
|---|---|---|
| H.262 | MPEG-2 Video | ISO/IEC 13818-2 |
| H.264 | AVC | MPEG-4 Part 10, ISO/IEC 14496-10 |
| H.265 | HEVC | MPEG-H Part 2, ISO/IEC 23008-2 |
| H.266 | VVC | MPEG-I Part 3, ISO/IEC 23090-3 |

AVC is Advanced Video Coding. HEVC is High Efficiency Video Coding. VVC is Versatile Video Coding.

A file labeled with either name of a pair is the same codec. A decoder for one name accepts the other.

VP9 and AV1 have a single name. Google published VP9. The Alliance for Open Media published AV1.
