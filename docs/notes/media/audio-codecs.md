# Audio codecs

**Big picture:** an audio codec compresses samples. Lossy codecs discard detail. Lossless codecs restore the same samples. Uncompressed audio stores every sample.

Related: [Codec](codec.md) · [Video codecs](video-codecs.md)

## Codecs

| Codec | Kind | Where it shows up |
|---|---|---|
| AAC | Lossy | The usual track beside H.264 or HEVC. Apple, YouTube, streaming. |
| MP3 | Lossy | Still everywhere. Needs a higher bitrate than AAC for a similar result. |
| Opus | Lossy | Voice and music, including very low bitrates. WebRTC, Discord, browsers. |
| Vorbis | Lossy | Ogg, and older WebM. |
| FLAC | Lossless | Music libraries and archives. Same samples as the source, smaller than WAV. |
| ALAC | Lossless | Apple's lossless codec. |
| WAV | Uncompressed | PCM samples. Masters and editing. |
| AC-3, E-AC-3 | Lossy surround | Dolby Digital and Dolby Digital Plus, on discs and streams. |
| LC3 | Lossy | Bluetooth LE Audio. |

## Kinds

Lossy
: The encoder discards detail. Decoding plays an approximation.

Lossless
: Decoding restores the samples that were encoded. FLAC and ALAC do this. The file is smaller than WAV and identical on playback.

Uncompressed
: Every sample is stored directly. WAV is this, using PCM.
