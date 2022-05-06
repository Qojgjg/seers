<script lang="ts">
  import SvelteMarkdown from "svelte-markdown"

  export let auth
  export let comments = []
  export let marketId
  export let readMarket

  let imageUrl = ""
  let comment = ""
  let commentLabel = "Comment"
  let commentErrorResponse = ""

  const splitCamelCaseToString = (s) => {
    return s
      .split(/(?=[A-Z])/)
      .map((p) => {
        return p[0].toUpperCase() + p.slice(1)
      })
      .join(" ")
  }

  const postComment = async () => {
    commentLabel = "Processing..."
    console.log(marketId)
    let response = await $auth.actor.addCommentToMarket(marketId, comment)

    if (response["err"]) {
      commentErrorResponse =
        "Error: " +
        splitCamelCaseToString(Object.keys(response["err"]).toString())
    } else {
      commentErrorResponse = ""
      readMarket()
      comment = ""
    }
    commentLabel = "Comment"
  }
</script>

<div style="width: 100%">
  <h3 style="text-align:start">Comments</h3>
  <div style="text-align:start">
    {#each comments as comment}
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
