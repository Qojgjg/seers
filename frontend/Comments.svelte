<script lang="ts">
  import SvelteMarkdown from "svelte-markdown"

  export let comments

  let imageUrl = ""
  let comment = ""
  let commentLabel = "Comment"
  let commentErrorResponse = ""
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
