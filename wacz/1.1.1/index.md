# Web Archive Collection Zipped (WACZ) 
 
> **非公式翻訳 (Unofficial translation).** これは WACZ 1.1.1 仕様の有志による日本語訳です。
> 正典は英語原典 <https://specs.webrecorder.net/wacz/1.1.1/> 。
> 原著作: Webrecorder, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)。
> 本訳は原文を翻訳・改変したもので、Webrecorder の公認・推奨を示すものではありません。

## Status of This Document

これは WACZ 標準の安定版であり、Webrecorder プロジェクトで実際に使用されています。
質問や提案は [GitHub issues](https://github.com/webrecorder/specs/issues/) を開いてください。

## Abstract

WACZ は、ウェブアーカイブの <a>collections</a> を 1 つの独立したファイルとして
<a>packaged</a> し、ウェブ上で共有できるようにする <a>media type</a> です。
WACZ ファイルには、アーカイブされたコンテンツの描画に必要なすべてのデータに加え、
利用者がそれを解釈するために必要な <a>contextual information</a> が含まれます。
描画ソフトウェアはこのデータを HTTP Range リクエストで必要に応じて取得でき、
ファイル全体を取得することも、専用のサーバーサイドソフトウェアを介することも
要しません。

## Terminology
      
この節では、本仕様およびウェブアーカイブ基盤全体で用いられる用語を定義する。
これらの用語が本仕様中に現れるたびに、その定義へのリンクが付与される。

<dl class="termlist">

<dt><dfn id="dfn-collection">Collection</dfn></dt>
<dd>トピック・ウェブサイトのドメイン・期間など、何らかの概念的なまとまりに基づく、関連するアーカイブ済みウェブページとメタデータの任意の集合。</dd>

<dt><dfn id="dfn-context" data-lt="contextual information">Context</dfn></dt>
<dd>あるウェブアーカイブに関する説明的な情報で、そのアーカイブを利用する人がアーカイブの内容を理解・解釈する助けとなるもの。この情報には、なぜそのコンテンツがアーカイブ対象として選ばれたか、いつ作成されたか、誰が作成したか、どのツールやアプリケーションを用いて作成したか、などが含まれうる。</dd>

<dt><dfn id="dfn-iipc">IIPC</dfn></dt>
<dd>国際インターネット保存コンソーシアム (International Internet Preservation Consortium)。ウェブコンテンツを保存する取り組みを調整するため 2003 年に設立された、図書館・アーカイブ機関などの組織。</dd>

<dt><dfn id="dfn-mediatype">Media Type</dfn></dt>
<dd>World Wide Web とその基盤であるインターネット上で転送されるファイル形式のための、2 部構成の識別子。[[IANA-MEDIA-TYPES]]。</dd>

<dt><dfn id="dfn-package" data-lt="packaging|packaged">Package</dfn></dt>
<dd>個別のファイルやビットストリームを内部に表現できるファイル形式。代表的なパッケージ形式の例として ZIP・PDF・MP4・tar・Open Office XML がある。</dd>

<dt><dfn id="dfn-webpage" data-lt="pages">Page</dfn></dt>
<dd>特定の URL を表示しているウェブブラウザで閲覧される web ドキュメント。<em>web page</em> と呼ばれることもある。</dd>

<dt><dfn id="dfn-wacz" data-lt="web archive collection">WACZ</dfn></dt>
<dd>Web Archive Collection Zipped。本仕様に準拠したファイルで、<a>WARC</a> データとメタデータを <a>ZIP</a> ファイルにパッケージ化し、ウェブ上での配布とリプレイに用いる。</dd>

<dt><dfn id="dfn-warc">WARC</dfn></dt>
<dd>[[WARC]] 仕様に準拠した、ウェブリソースの表現を連結して格納したファイル。</dd>

<dt><dfn id="dfn-wayback">Wayback Machine</dfn></dt>
<dd>アーカイブ済みウェブページをリプレイするための著名なウェブアプリケーション。当初 Internet Archive で開発され、<a>IIPC</a> によってオープンソースアプリケーションとして fork された。</dd>

<dt><dfn id="dfn-web-archive">Web Archive</dfn></dt>
<dd>ウェブリソースの表現を WARC 形式で保存するファイルの集合。ウェブアーカイブには、アーカイブ内のレコードへアクセスするための CDX インデックスなどの派生ファイルが含まれることもある。</dd>

<dt><dfn id="dfn-zip-file" data-lt="zip">ZIP file</dfn></dt>
<dd>[[ZIP]] 仕様に準拠したファイルで、複数のファイルを単一の相互運用可能なコンテナに集約・圧縮・暗号化するために用いられる。WACZ は、より大きなアーカイブのために ZIP と ZIP64 の両エンコーディングを許容する。</dd>

</dl>

## Introduction

本仕様は、<a>web archives</a> を共有・配布するためのディレクトリ構造と
<a>ZIP</a> 形式の仕様を定義する。この形式を用いた <a>ZIP</a> ファイルは
<a>WACZ</a>(Web Archive Collection Zipped)と呼ぶことができる。

### Motivation

本仕様の目標は、<a>web archives</a> のための可搬な形式を提供し、
ウェブアーカイブに関する 2 つの大きな目標を達成することである:

1. *Social*: ウェブアーカイブの <a>collections</a> を、利用者がそれらを解釈し
   意味のある形で操作するために必要な <a>contextual information</a> とともに、
   相互運用可能な方法で共有する手段を提供すること。

2. *Technical*: 静的ストレージ上にリモートホストされたファイルから
   *少量のデータ* を動的に読み込む効率的な手段を、ファイル全体の
   ダウンロードや専用のサーバーサイドアプリケーションの介在を必要とせずに
   提供すること。

ウェブアーカイブコレクションを利用し理解するには、アーカイブされたウェブ
コンテンツに加え、そのコレクションが何を含み、いつ・どのように作成されたかを
記述する <a>contextual information</a> が必要である。また、コレクションを閲覧する
ための入口となる <a>pages</a> の集合も必要となる。

これらのデータはすべて一緒に <a>packaged</a> される必要がある。そうすることで、
各部分を誤って分離させることなく容易にコピー・転送できる。このデータパッケージは、
あるストレージシステムから別のシステムへ容易に移送でき、電子メールの添付として
送れ、USB メモリに入れられ、そして(クラウドオブジェクトストレージや CDN から)
指定された URL で静的ドキュメントとして配信するだけでホストできる必要がある。

現在、ウェブアーカイブをホストするには、ブラウザで閲覧できる形で <a>WARC</a>
データを配信するための複雑なサーバーインフラ(例: <a>Wayback Machine</a>)が
必要である。<a>WACZ</a> 形式は、<a>packaged</a> された WARC データへの効率的な
ランダムアクセスに最適化されたストレージ手法を提供し、ブラウザが特定のページに
必要なものだけを取得してそのページを描画できるようにする。これは、ウェブ
アーカイブの内容とそれを構成するメタデータの位置特定に <a>ZIP</a> 形式の
組み込みインデックスを活用することで実現される。

WACZ は他のウェブアーカイブ形式を置き換えることを意図したものではない。むしろ、
ウェブアーカイブコレクションの効率的な描画とその文脈付けのためにブラウザが
必要とするすべてのデータについて、ファイルの <a>packaging</a> 規約を定めるもので
ある。

### Existing Tools 

[py-wacz](https://github.com/webrecorder/py-wacz) リポジトリには、既存の WARC
ファイルから WACZ ファイルを作成し、それらを検証するためのリファレンス実装が
含まれている。本仕様の一部は [wabac.js](https://github.com/webrecorder/wabac.js)
および [ReplayWeb.page](https://replayweb.page) でも実装・利用されている。

## WACZ Object

A WACZ object consists of the following:

1. A `datapackage.json` file for recording technical and descriptive metadata
   specified in [[FRICTIONLESS-DATA-PACKAGE]].

2. An extensible directory and naming convention for <a>web archive</a> data.

3. A method for bundling the directory layout in a <a>ZIP</a> file.

### Directory Layout

A <a>WACZ</a> contains a directory structure, that contains web archive
collection data which MUST conform to the [[FRICTIONLESS-DATA-PACKAGE]]
specification. This directory structure looks like:

<pre class="example">
├── archive
│   └── data.warc.gz
├── datapackage.json
├── datapackage-digest.json
├── indexes
│   └── index.cdx.gz
└── pages
    └── pages.jsonl
</pre>

### Directories and Files

#### archive

The `archive` directory MUST contain one or more files in the [[WARC]] format. 
The files SHOULD use the `.warc` file extension unless they are GZIP encoded in 
which case they MUST use the `.warc.gz` file extension.

<pre class="example">
archive
└── data.warc
</pre>

#### indexes

The `indexes` directory MUST include one or more indexes for the WARC data stored
in `archive`. These index files allow clients to efficiently look up a URL to
see if it is contained in the WACZ. Index files MUST contain CDXJ data
and MAY be gzip compressed [[PYWB-CDXJ]].

<pre class="example">
indexes
└── index.cdx.gz
</pre>

#### pages.jsonl

The `pages/pages.jsonl` MUST be present and include a list of 'Page' objects as
[[JSON-Lines]] where each line MUST contain at least the following properties:

- `url` - a URL for the page
- `ts` - a [[RFC3339]] datetime string

Each entry in the [[JSONL]] file MAY contain the following properties to aid in
navigating a web archive collection:

- `title` - a string describing the resource
- `id` - an arbitrary identifier for the resource
- `text` - text extracted from the snapshot
- `size` - an integer that represents the number of bytes for the page and all its resources

<pre class="example">
{"format": "json-pages-1.0", "id": "pages", "title": "All Pages"}
{"id": "1db0ef709a", "url": "https://www.example.com/page", "size": 1256, "ts": "2020-10-07T21:22:36Z", "title": "Example Domain", "text": "Example Domain This domain is for use in illustrative examples in documents. You may use this domain in literature without prior coordination or asking for permission. More information..."}
{"id": "12304e6ba9", "url": "https://www.example.com/another", "size": 1256, "ts": "2020-10-07T21:23:36Z", "title": "Another Page", "text": "Example Domain This domain is for use in illustrative examples in documents. You may use this domain in literature without prior coordination or asking for permission. More information..."}
</pre>

Each entry in the [[JSONL]] file MAY contain additional properties as long as
they do not interfere with the required properties.

Other [[JSONL]] files MAY be added on using the same format in the `pages/`
directory. A common use case is to include only the main pages in the
`pages.jsonl`, while including additional pages, such as those discovered
automatically via a crawl in an another file e.g. `extraPages.jsonl`.

#### datapackage.json

The `datapackage.json` file MUST be present at the root of the WACZ which
serves as the manifest for the web archive and is compliant with the
[[FRICTIONLESS-DATA-PACKAGE]] specification. It MUST contain the following
properties:

- `profile`: the string `data-package`
- `resources`: a list of file names, paths, sizes and fixity for all files
   contained in the WACZ.
- `wacz_version`: the version of WACZ used, for example `1.1.1`

<pre class="example">
{
  "profile": "data-package",
  "wacz_version": "1.1.1",
  "resources": [
     {
       "name": "pages.jsonl",
       "path": "pages/pages.jsonl",
       "hash": "sha256:8a7fc0d302700bed02294404a627ddbbf0e35487565b1c6181c729dff8d2fff6",
       "bytes": 75
     },
     {
       "name": "data.warc",
       "path": "archive/data.warc",
       "hash": "sha256:0e7101316ba5d4b66f86a371ee615fbd20f9d3f32d32563ed2c829db062f7714",
       "bytes": 11469796
     }
  ]
}
</pre>

The `datapackage.json` SHOULD include properties that allow rendering
applications to present the user with <a>contextual information</a> about the
web archive:

- `title`: a string or one sentence description for the collection
- `description`: a longer description of the archive's contents 
   which MUST be Markdown formatted (plain text is valid Markdown)
- `created`: a [[RFC3339]] datetime for when the WACZ file was created
- `modified`: a [[RFC3339]] datetime for when the WACZ file was last modified
- `software`: A description of what software was used to create the WACZ file
- `mainPageUrl`: An optional URL of the main or starting page in the collection
  to be used for initial replay
- `mainPageDate`: An optional ISO-formatted date of the main or starting page in 
  the collection to be used for initial replay

Other properties from the [[FRICTIONLESS-DATA-PACKAGE]] specification such as
`licenses`, `version`, `organization`, `contributors`, `email` MAY be used. 
Custom properties that do not interfere with pre-existing properties MAY also 
be used.

#### datapackage-digest.json

A `datapackage-digest.json` file SHOULD be included in the root of the WACZ to
verify the `datapackage.json` manifest with a hash and thus for the entire
contents of the WACZ. If present the following properties MUST be included:

* `path`: the string "datapackage.json"
* `hash`: a cryptographic hash for the `datapackage.json` file

<pre class="example">
{
  "path": "datapackage.json",
  "hash": "sha256:ec1f44ab13e2c94b0ddf66e9673d585ba4a77e6f8c9cc30d8665da434557e885"
}
</pre>

For an approach to recording a cryptographic signature in the
`datapackage-digest.json` in order to assert and prove the authorship of a WACZ
please see [WACZ Signing and Verification](/wacz-auth/latest/).

### Other files and directories

Other files and directories MAY be present in a WACZ as long as they do 
not interfere with specified files and directories that are used by WACZ.
Specifically, custom files and directories MUST NOT be added to the existing WACZ directories, `archive`, `indexes` and `pages`. Additional files MUST be listed in the resources section of `datapackage.json` to ensure conformance with [[FRICTIONLESS-DATA-PACKAGE]]

### Zip Format

The entire directory structure MUST be stored in a standard [[ZIP]] file.

#### Zip Compression

Already compressed files MUST NOT be compressed again to allow for random access.

- All `archive/` files should be stored in ZIP with 'STORE' mode.
- All `index/*.cdx.gz` files should be stored in ZIP with 'STORE' mode.
- All files (`*.jsonl`, `*.json`, `*.idx`, `*.cdx`, `*.cdxj`) can be stored in 
  the ZIP with either 'DEFLATE' or 'STORE' mode.

#### Zip Format File Extension

A ZIP file that follows this Web Archive Collection format spec MUST use the extension `.wacz`.

Such a file can be referred to as a WACZ file or a WACZ.

## Processing Model

The [[ZIP]] file format provides efficient random access, which means archived
web pages can be retrieved efficiently even from large web archive collections
without requiring the entire WACZ to be transferred. To achieve this WACZ
clients can read portions of the ZIP file on-demand using HTTP RANGE requests
[[RFC7233]].

The processing model works as follows. Given a ZIP file, a client can quickly:

1. Read all entries to determine the contents of the ZIP file
2. Load collection metadata from the `datapackage.json`
3. Load a list of pages from `pages.jsonl`, if any

To lookup a given URL the client needs to:

1. Read the full CDX from ZIP
2. Binary search index looking for the URL
3. If a match found, get offset/length/location in WARC
4. Read compressed WARC chunk in ZIP

This approach is being used by [ReplayWeb.page](https://replayweb.page)

## Publishing

Because they are ZIP files WACZ can be hosted on the web as static files. This
allows web archives to be easily maintained over time without relying on complex
server side software, apart from widely available, open source, and well tested
web server applications. If desirable WACZ files can be managed and made
accessibile using HTTP object stores available from cloud hosting providers, and
content deliver networks that geographically position web-archives closer to
their users. However there are certain considerations to make when publishing
WACZ files.

### Content-Length

WACZ clients need to know how large an entire WACZ file is in order to
download it prior to rendering, or to read it dynamically. To support this HTTP
responses for WACZ files MUST use the `Content-Length` HTTP header.

### Partial Requests

Clients that render WACZ files typically need to be able to fetch content from
the WACZ file on demand. For example when displaying archived content for a
given URL that URL needs to be looked up in the CDXJ index, and the byte offsets
from the index entry are then used to retrieve a portion of a given WARC file
that is enclosed in the WACZ.

In order for clients to be able to perform this dynamic retrieval web servers
that publish WACZ files MUST support HTTP range requests [[RFC7233]]. HTTP
responses for WACZ HTTP requests SHOULD server WACZ files using the
`Accept-Ranges` HTTP header.

### CORS

WACZ files and the their clients MAY be served from the same host name. However
it can be useful to view the web archive from a host name that is distinct from
the host name that is publishing the WACZ file. For example this is the
case when publishing WACZ files using a cloud provider's HTTP object storage
(e.g. `s3.amazonaws.com`) and making it viewable at another domain (`e.g.
example.org`). It also is the case when WACZ publishers want to allow their web
archives to circulate on the web, and be viewable in multiple locations.

For security reasons browsers restrict access to files hosted on a
different domain than the websites that is trying to load them. In order to
support loading from different domains WACZ files SHOULD be made available using
the `access-control-allow-origin` [[CORS]] HTTP header.

### Media Type

WACZ HTTP responses for WACZ files SHOULD be published with the
`application/wacz` media type.

### Example Response

Given these requirements a minimal HTTP response for a WACZ could look
like:

<pre class="example">
HTTP/2 200
Content-Type: application/wacz
Content-Length: 20961755
Accept-Ranges: bytes
Access-Control-Allow-Origin: *
</pre>
