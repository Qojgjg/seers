<script lang="ts">
  import SvelteMarkdown from "svelte-markdown"

  let imageUrl = ""
  let comment = ""
  let commentLabel = "Comment"
  let commentErrorResponse = ""
  let comments = [
    {
      author: "Marcio",
      content: "This is first comment.",
    },
    {
      author: "Jose",
      content:
        "If Twitter announces it will no longer agree to the terms of its initial agreement or announcement after previously announcing that it would agree to an acquisition by Elon Musk, or an acquisition by or merger with any entity controlled by Elon Musk, it will have no bearing on the resolution of this market. This market will resolve to 'Yes' solely based on whether Twitter makes an initial announcement that it is agreeing to an acquisition by Elon Musk, or an acquisition by or merger with any entity controlled by Elon Musk. The primary resolution source for this market will be official information from Twitter (e.g. https://twitter.com/twitter, https://blog.twitter.com/, etc.); however, other credible reporting may be used to resolve this market.",
    },
  ]
  let market = { imageUrl, comments }

  const postComment = () => {}
</script>

<div style="width: 100%">
  <h3 style="text-align:start">Comments</h3>
  <div style="text-align:start">
    {#each market.comments as comment}
      <div style="margin: 5px 0px">
        <div style="color:pink; padding: 5px 0px">{comment.author}</div>
        <SvelteMarkdown source={comment.content} />
      </div>
    {/each}
    <div class="comment-container">
      <textarea
        bind:value={comment}
        rows="10"
        style="height: auto; width: 100%; font-size: 1.3em"
        placeholder="Please share your insight"
      />
      <div style="display:flex; justify-content: right">
        <button class="btn-grad" on:click={postComment}>
          {commentLabel}
        </button>
      </div>
      <div style="width: 100%;text-align:center;color:red">
        {commentErrorResponse}
      </div>
    </div>
  </div>
</div>
