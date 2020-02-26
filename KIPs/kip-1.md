---
kip: 1
title: KIP Purpose and Guidelines
author: Junghyun Kim <colin.kim@groundx.xyz>
status: Active
type: Meta
created: 2019-11-10
---

## What is a KIP?

KIP stands for Klaytn Improvement Proposal. A KIP is a design document providing information to the Klaytn community, or describing a new feature for Klaytn or its processes or environment. The KIP should provide a concise technical specification of the feature and a rationale for the feature. The KIP author is responsible for building consensus within the community and documenting dissenting opinions.

## KIP Rationale

We intend KIPs to be the primary mechanisms for proposing new features, for collecting community technical input on an issue, and for documenting the design decisions that have gone into Klaytn. Because the KIPs are maintained as text files in a versioned repository, their revision history is the historical record of the feature proposal.

For Klaytn implementers, KIPs are a convenient way to track the progress of their implementation. Ideally each implementation maintainer would list the KIPs that they have implemented. This will give end users a convenient way to know the current status of a given implementation or library.

## KIP Types

There are three types of KIP:

- A **Standard Track KIP** describes any change that affects most or all Klaytn implementations, such as a change to the network protocol, a change in block or transaction validity rules, proposed application standards/conventions, or any change or addition that affects the interoperability of applications using Klaytn. Furthermore Standard Track KIPs can be broken down into the following categories. Standards Track KIPs consist of two parts, a design document and implementation.
  - **Core** - improvements requiring a consensus fork as well as changes that are not necessarily consensus critical but may be relevant to core development.
  - **Networking** - includes improvements related to networking layers.
  - **Storage** - includes improvements related to storage layers.
  - **Interface** - includes improvements around client API/RPC specifications and standards, and also certain language-level standards like method names and contract ABIs.
  - **Token** - includes improvements or standards related to tokens.
  - **SDK** - includes improvements related to SDKs.
  - **Application** - application-level standards and conventions, such as name registries, URI schemes, library/package formats, and wallet formats.
- A **Meta KIP** describes a process surrounding Klaytn or proposes a change to (or an event in) a process. Meta KIPs are like Standard Track KIPs but apply to areas other than the Klaytn protocol itself. They may propose an implementation, but not to Klaytn's codebase; they often require community consensus; unlike Informational KIPs, they are more than recommendations, and users are typically not free to ignore them. Examples include procedures, guidelines, changes to the decision-making process, and changes to the tools or environment used in Klaytn development. Any Meta KIP is also considered a Process KIP.
- An **Informational KIP** describes a Klaytn design issue, or provides general guidelines or information to the Klaytn community, but does not propose a new feature. Informational KIPs do not necessarily represent Klaytn community consensus or a recommendation, so users and implementers are free to ignore Informational KIPs or follow their advice.

It is highly recommended that a single KIP contains a single key proposal or new idea. The more focused the KIP, the more successful it tends to be. A change to one client doesn't require a KIP; a change that affects multiple clients, or defines a standard for multiple apps to use, does.

A KIP must meet certain minimum criteria. It must be a clear and complete description of the proposed enhancement. The enhancement must represent a net improvement. The proposed implementation, if applicable, must be solid and must not complicate the protocol unduly.

### Special requirements for Core KIPs

If a **Core** KIP mentions or proposes changes to the KLVM (KLaytn Virtual Machine, forked from Byzantium EVM), it should refer to the instructions by their mnemonics and define the opcodes of those mnemonics at least once. A preferred way is the following:
```
REVERT (0xfe)
```

## KIP Work Flow

### Shepherding a KIP

Parties involved in the process are you, the champion or *KIP author*, the [*KIP editors*](#kip-editors), and the Klaytn core developers.

Before you begin writing a formal KIP, you should vet your idea. Ask the Klaytn community first if an idea is original to avoid wasting time on something that will be be rejected based on prior research. It is thus recommended to open a discussion thread on [the Issues section of this repository](https://github.com/klaytn/KIPs/issues). 

In addition to making sure your idea is original, it will be your role as the author to make your idea clear to reviewers and interested parties, as well as inviting editors, developers and community to give feedback on the aforementioned channels. You should try and gauge whether the interest in your KIP is commensurate with both the work involved in implementing it and how many parties will have to conform to it. For example, the work required for implementing a Core KIP will be much greater than for others and the KIP will need sufficient interest from the Klaytn client teams. Negative community feedback will be taken into consideration and may prevent your KIP from moving past the Draft stage.

### Core KIPs

For Core KIPs, given that they require client implementations to be considered **Final** (see "KIPs Process" below), you will need to either provide an implementation for clients or convince clients to implement your KIP. 

In short, your role as the champion is to write the KIP using the style and format described below, shepherd the discussions in the appropriate forums, and build community consensus around the idea.

### KIP Process 

Following is the process that a successful KIP will move along:

```
[ IDEA ] -> [ DRAFT ] -> [ LAST CALL ] -> [ ACCEPTED ] -> [ FINAL ]
```

Each status change is requested by the KIP author and reviewed by the KIP editors. Use a pull request to update the status. Please include a link to where people should continue discussing your KIP. The KIP editors will process these requests as per the conditions below.

* **Idea** -- Once the champion has asked the Klaytn community whether an idea has any chance of support, they will write a draft KIP as a [pull request](https://github.com/klaytn/KIPs/pulls). Consider including an implementation if this will aid people in studying the KIP.
  * :arrow_right: Draft -- If agreeable, a KIP editor will assign the KIP a number (generally the issue or PR number related to the KIP) and merge your pull request. The KIP editor will not unreasonably deny a KIP.
  * :x: Draft -- Reasons for denying draft status include being too unfocused, too broad, duplication of effort, being technically unsound, not providing proper motivation or addressing backwards compatibility.
* **Draft** -- Once the first draft has been merged, you may submit follow-up pull requests with further changes to your draft until such point as you believe the KIP to be mature and ready to proceed to the next status. A KIP in draft status must be implemented to be considered for promotion to the next status.
  * :arrow_right: Last Call -- If agreeable, the KIP editor will assign Last Call status and set a review end date (`review-period-end`), normally 14 days later.
  * :x: Last Call -- A request for Last Call status will be denied if material changes are still expected to be made to the draft. We hope that KIPs only enter Last Call once.
* **Last Call** -- This KIP will listed prominently as a pinned issue.
  * :x: -- A Last Call which results in material changes or substantial unaddressed technical complaints will cause the KIP to revert to Draft.
  * :arrow_right: Accepted -- A successful Last Call without material changes or unaddressed technical complaints will become Accepted.
* **Accepted** -- This status signals that material changes are unlikely and Klaytn client developers should consider this KIP for inclusion. Their process for deciding whether to encode it into their clients as part of a hard fork is not part of the KIP process.
  * :arrow_right: Draft -- The KIP can be decided to move it back to the Draft status at the discretion. E.g. a major, but correctable, flaw was found in the KIP.
  * :arrow_right: Rejected -- The KIP can be decided to be marked as this KIP as Rejected at their discretion. E.g. a major, but uncorrectable, flaw was found in the KIP.
  * :arrow_right: Final -- Standard Track Core KIPs must be implemented in any of Klaytn clients before it can be considered Final. When the implementation is complete and adopted by the community, the status will be changed to “Final”.
* **Final** -- This KIP represents the current state-of-the-art. A Final KIP should only be updated to correct errata.

Other exceptional statuses include:

* **Active** -- Some Informational and Process KIPs may also have a status of “Active” if they are never meant to be completed. E.g. KIP 1 (this KIP).
* **Abandoned** -- This KIP is no longer pursued by the original authors or it may not be a (technically) preferred option anymore.
  * :arrow_right: Draft -- Authors or new champions wishing to pursue this KIP can ask for changing it to Draft status.
* **Rejected** -- A KIP that is fundamentally broken or a Core KIP that was rejected by the Core Devs and will not be implemented. A KIP cannot move on from this state.
* **Superseded** -- A KIP which was previously Final but is no longer considered state-of-the-art. Another KIP will be in Final status and reference the Superseded KIP. A KIP cannot move on from this state.

## What belongs in a successful KIP?

Each KIP should have the following parts:

- Preamble - RFC 822 style headers containing metadata about the KIP, including the KIP number, a short descriptive title (limited to a maximum of 44 characters), and the author details. See [below](#kip-header-preamble) for details.
- Abstract - A short (~200 word) description of the technical issue being addressed.
- Motivation (*optional) - The motivation is critical for KIPs that want to change the Klaytn protocol. It should clearly explain why the existing protocol specification is inadequate to address the problem that the KIP solves. KIP submissions without sufficient motivation may be rejected outright.
- Specification - The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Klaytn platforms.
- Rationale - The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.
- Backwards Compatibility - All KIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The KIP must explain how the author proposes to deal with these incompatibilities. KIP submissions without a sufficient backwards compatibility treatise may be rejected outright.
- Test Cases - Test cases for an implementation are mandatory for KIPs that are affecting consensus changes. Other KIPs can choose to include links to test cases if applicable.
- Implementations - The implementations must be completed before any KIP is given status “Final”, but it need not be completed before the KIP is merged as draft. While there is merit to the approach of reaching consensus on the specification and rationale before writing code, the principle of “rough consensus and running code” is still useful when it comes to resolving many discussions of API details.
- Copyright Waiver - All KIPs must be in the public domain. See the bottom of this KIP for an example copyright waiver.

## KIP Formats and Templates

KIPs should be written in [markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) format.
Image files should be included in a subdirectory of the `assets` folder for that KIP as follows: `assets/kip-N` (where **N** is to be replaced with the KIP number). When linking to an image in the KIP, use relative links such as `../assets/kip-1/image.png`.

## KIP Header Preamble

Each KIP must begin with an [RFC 822](https://www.ietf.org/rfc/rfc822.txt) style header preamble, preceded and followed by three hyphens (`---`). This header is also termed ["front matter" by Jekyll](https://jekyllrb.com/docs/front-matter/). The headers must appear in the following order. Headers marked with "*" are optional and are described below. All other headers are required.

` kip:` *KIP number* (this is determined by the KIP editor)

` title:` *KIP title*

` author:` *a list of the author's or authors' name(s) and/or username(s), or name(s) and email(s). Details are below.*

` * discussions-to:` *a url pointing to the official discussion thread*

` status:` *Draft | Last Call | Accepted | Final | Active | Abandoned | Rejected | Superseded*

` * review-period-end:` *date review period ends*

` type:` *Standards Track | Informational | Meta*

` * category:` *Core | Networking | Storage | Interface | Token | SDK | Application* (Standards Track KIPs only)

` created:` *date created on*

` * updated:` *comma separated list of dates*

` * requires:` *KIP number(s)*

` * replaces:` *KIP number(s)*

` * superseded-by:` *KIP number(s)*

` * resolution:` *a url pointing to the resolution of this KIP*

Headers that permit lists must separate elements with commas.

Headers requiring dates will always do so in the format of ISO 8601 (yyyy-mm-dd).

#### `author` header

The `author` header optionally lists the names, email addresses or usernames of the authors/owners of the KIP. Those who prefer anonymity may use a username only, or a first name and a username. The format of the author header value must be:

> Random J. User &lt;address@dom.ain&gt;

or

> Random J. User (@username)

if the email address or GitHub username is included, and

> Random J. User

if the email address is not given.

#### `resolution` header

The `resolution` header is required for Standards Track KIPs only. It contains a URL that should point to an email message or other web resource where the pronouncement about the KIP is made.

#### `discussions-to` header

While a KIP is a draft, a `discussions-to` header will indicate the mailing list or URL where the KIP is being discussed. As mentioned above, examples for places to discuss your KIP include an issue in this repo or in a fork of this repo.

No `discussions-to` header is necessary if the KIP is being discussed privately with the author.

As a single exception, `discussions-to` cannot point to GitHub pull requests.

#### `type` header

The `type` header specifies the type of KIP: Standards Track, Meta, or Informational. If the track is Standards Track, please include the subcategory (core, networking, storage, interface, token, SDK or application).

#### `category` header

The `category` header specifies the KIP's category. This is required for standards-track KIPs only.

#### `created` header

The `created` header records the date that the KIP was assigned a number. Both headers should be in yyyy-mm-dd format, e.g. 2001-08-14.

#### `updated` header

The `updated` header records the date(s) when the KIP was updated with "substantial" changes. This header is only valid for KIPs of Draft and Active status.

#### `requires` header

KIPs may have a `requires` header, indicating the KIP numbers that this KIP depends on.

#### `superseded-by` and `replaces` headers

KIPs may also have a `superseded-by` header indicating that a KIP has been rendered obsolete by a later document; the value is the number of the KIP that replaces the current document. The newer KIP must have a `replaces` header containing the number of the KIP that it rendered obsolete.

## Auxiliary Files

KIPs may include auxiliary files such as diagrams. Such files must be named KIP-XXXX-Y.ext, where “XXXX” is the KIP number, “Y” is a serial number (starting at 1), and “ext” is replaced by the actual file extension (e.g. “png”).

## Transferring KIP Ownership

It occasionally becomes necessary to transfer ownership of KIPs to a new champion. In general, we'd like to retain the original author as a co-author of the transferred KIP, but that's really up to the original author. A good reason to transfer ownership is because the original author no longer has the time or interest in updating it or following through with the KIP process, or has fallen off the face of the 'net (i.e. is unreachable or isn't responding to email). A bad reason to transfer ownership is because you don't agree with the direction of the KIP. We try to build consensus around a KIP, but if that's not possible, you can always submit a competing KIP.

If you are interested in assuming ownership of a KIP, send a message asking to take over, addressed to both the original author and the KIP editor. If the original author doesn't respond to email in a timely manner, the KIP editor will make a unilateral decision (it's not like such decisions can't be reversed :)).

## KIP Editors

The current KIP editors are

` * Kyungup Kim (@KimKyungup)`

` * Junghyun Colin Kim (@kjhman21)`

` * Sangmin Seo (@smseo)`

## KIP Editor Responsibilities

For each new KIP that comes in, an editor does the following:

- Read the KIP to check if it is ready: sound and complete. The ideas must make technical sense, even if they don't seem likely to get to final status.
- The title should accurately describe the content.
- Check the KIP for language (spelling, grammar, sentence structure, etc.), markup (Github flavored Markdown), code style

If the KIP isn't ready, the editor will send it back to the author for revision, with specific instructions.

Once the KIP is ready for the repository, the KIP editor will:

- Assign a KIP number (generally the PR number or, if preferred by the author, the Issue # if there was discussion in the Issues section of this repository about this KIP)

- Merge the corresponding pull request

- Send a message back to the KIP author with the next step.

Many KIPs are written and maintained by developers with write access to the Klaytn codebase. The KIP editors monitor KIP changes, and correct any structure, grammar, spelling, or markup mistakes we see.

The editors don't pass judgment on KIPs. We merely do the administrative & editorial part.

## History

This document was derived heavily from [Ethereum's EIP-1](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1.md) written by Martin Becze, Hudson Jameson, et al.

[Ethereum's EIP-1](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1.md) was derived heavily from [Bitcoin's BIP-0001](https://github.com/bitcoin/bips) written by Amir Taaki which in turn was derived from [Python's PEP-0001](https://www.python.org/dev/peps/). In many places text was simply copied and modified.

The authors of the documents are not responsible for its use in the Klaytn Improvement Proposal, and should not be bothered with technical questions specific to Klaytn or the KIP. Please direct all comments to the KIP editors.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
