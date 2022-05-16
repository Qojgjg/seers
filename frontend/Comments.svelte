<script lang="ts">
  import { Principal } from "@dfinity/principal"
  import SvelteMarkdown from "svelte-markdown"

  export let auth
  export let marketId
  export let readMarket
  export let comments = []
  export let signIn
  export let principal

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
    <div class="comment-container">
      <textarea
        bind:value={comment}
        rows="5"
        style="height: auto; width: 95%; font-size: 1.3em; background: rgb(25, 27, 31);color:white;border: 0px solid rgb(90, 58, 81); padding: 10px"
        placeholder="Please share your insights. You can use markdown."
      />
      {#if principal === ""}
        <div style="display:flex; justify-content: right; width: 95%">
          <button class="btn-grad" on:click={() => signIn()}> Login </button>
        </div>
      {:else}
        <div style="display:flex; justify-content: right; width: 95%">
          <button class="btn-grad" on:click={postComment}>
            {commentLabel}
          </button>
        </div>
      {/if}
      <div style="width: 100%;text-align:center;color:red">
        {commentErrorResponse}
      </div>
    </div>
    {#each comments as comment}
      <div style="margin: 5px 0px">
        <div
          style="display:flex; gap: 20px; margin: 15px 0px; min-height: 100px"
        >
          <img
            src={comment.picture}
            alt="pic"
            style="width: 70px; height: 70px; border-radius: 50%"
          />
          <div>
            <div style="color:pink; padding: 0px 0px">{comment.handle}</div>
            <SvelteMarkdown source={comment.content} />
          </div>
        </div>
      </div>
    {/each}
  </div>
</div>
