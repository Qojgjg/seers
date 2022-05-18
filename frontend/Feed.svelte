<script lang="ts">
  import { onMount } from "svelte"
  import SvelteMarkdown from "svelte-markdown"
  import inf from "./assets/inf.gif"

  export let auth
  export let principal
  export let signIn

  let post = ""
  let errorResponse = ""
  let feed = []

  const submitPost = async () => {
    const r = await $auth.actor.submitPost(post)
    post = ""
    console.log(r)
  }

  const getFeed = async () => {
    feed = await $auth.actor.getFeed()
  }

  onMount(getFeed)
</script>

<div
  style="justify-content: center; display: flex;width: 100%; margin-top: 20px; flex-direction:column; align-items:center; gap: 20px"
>
  <div class="rowUser">
    <div style="width: 100%; margin: 0px; padding: 5px">
      <textarea
        bind:value={post}
        rows="1"
        style="width: 100%; font-size: 1.3em; background: rgb(25, 27, 31);color:white;border: 0px solid rgb(90, 58, 81); padding: 5px; border-radius: 15px"
        placeholder="Please share your insights. You can use markdown."
      />
      <div style="display:flex; text-align:end; justify-content:end;">
        <button class="btn-grad" on:click={submitPost}>Post</button>
        <div style="text-align:end;color:red">
          {errorResponse}
        </div>
      </div>
    </div>
  </div>
  <div style="width: 100%; display:flex; justify-content:center">
    {#each feed as item}
      <div class="rowUser">
        <div style="width: 100%; text-align:start; padding: 5px;">
          {item.content}
        </div>
      </div>
    {/each}
  </div>
</div>
