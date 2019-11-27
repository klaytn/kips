## Klaytn Improvement Proposals (KIPs)

Klaytn Improvement Proposals (KIPs) describe standards for the Klaytn platform, including core protocol specifications, client APIs, and contract standards.

## Contributing

 1. Review [KIP-1](KIPs/kip-1.md).
 2. Fork the repository by clicking "Fork" in the top right.
 3. Add your KIP to your fork of the repository. There is a [template KIP here](https://github.com/ground-x/KIPs/blob/master/kip-template.md).
 4. Submit a Pull Request to Klaytn's [KIPs repository](https://github.com/ground-x/KIPs).

Your first PR should be a first draft of the final KIP. It must meet the formatting criteria enforced by the build (largely, correct metadata in the header). An editor will manually review the first PR for a new KIP and assign it a number before merging it. Make sure you include a `discussions-to` header with the URL to a discussion forum or open GitHub issue where people can discuss the KIP as a whole.

If your KIP requires images, the image files should be included in a subdirectory of the `assets` folder for that KIP as follows: `assets/kip-N` (where **N** is to be replaced with the KIP number). When linking to an image in the KIP, use relative links such as `../assets/kip-1/image.png`.

Once your first PR is merged, we have a bot that helps out by automatically merging PRs to draft KIPs. For this to work, it has to be able to tell that you own the draft being edited. Make sure that the 'author' line of your KIP contains either your Github username or your email address inside <triangular brackets>. If you use your email address, that address must be the one publicly shown on [your GitHub profile](https://github.com/settings/profile).

When you believe your KIP is mature and ready to progress past the draft phase, you should do the following:

 - Open a PR changing the state of your KIP to 'Last Call'. An editor will review your draft and see if there is a rough consensus to move forward. If there are significant issues with the KIP - they may close the PR and request that you fix the issues in the draft before trying again.
 - Before moving to 'Last Call', a reference implementation of the KIP should be provided. 

## KIP Status Terms

* **Draft** - a KIP that is undergoing rapid iteration and changes.
* **Last Call** - a KIP that is done with its initial iteration and ready for review by a wide audience for two weeks.
* **Accepted** - a KIP that has been in 'Last Call' for at least 2 weeks, any technical changes that were requested have been addressed by the author, and finally get approved by the Klaytn core developers. 
* **Final** - a KIP that has been released as a standard specification. If a Core KIP is in 'Final', its implementation has been included in at least one Klaytn client.


{% include types_lastcall.html %} 
