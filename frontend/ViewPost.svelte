<script lang="ts">
  import { onMount } from "svelte"

  import DisplayPost from "./DisplayPost.svelte"
  import DisplayButton from "./DisplayButton.svelte"

  export let auth
  export let principal
  export let signIn
  export let id

  let post = null
  let newComment = ""
  let errorResponse = ""
  let processing = false
  let replies = []
  let ancestors = []

  const submitReply = async () => {
    console.log(post.author)
    processing = true
    const initData = {
      id: 0,
      content: newComment,
      author: {
        principal,
        picture: "",
        handle: "",
        name: "",
      },
      parent: [
        {
          id: Number(post.id),
          author: post.author,
        },
      ],
      retweet: [],
      image: [],
      market: [],
      isRetweet: [],
    }

    const resp = await $auth.actor.submitPost(initData, [])
    processing = false
    newComment = ""
    console.log(resp)
    getPost()
  }

  const getPost = async () => {
    post = await $auth.actor.getThread(Number(id))
    if ("ok" in post) {
      console.log(post)
      replies = post["ok"].replies.reverse()
      ancestors = post["ok"].ancestors.reverse()
      post = post["ok"].main
    } else {
      console.log(post["err"])
    }
  }

  onMount(getPost)
</script>

<div
  style="justify-content: center; display: flex;width: 100%; flex-direction:column; align-items:center; margin-top: 50px"
>
  <div class="rowUser">
    {#each ancestors as post, i}
      <DisplayPost
        {auth}
        {principal}
        {signIn}
        {post}
        isThread={true}
        doNotShowParent={true}
      />
    {/each}
    <div
      id="main"
      style="padding: 0px 0px 0px 0px; width: 100%; border-top: 0px solid grey; "
    >
      <DisplayPost {auth} {principal} {signIn} {post} isMain={true} />
    </div>

    <div
      style={`width: 100%; margin: 15px 0px; padding: 15px 0px; border-bottom: ${
        replies.length > 0 ? 1 : 0
      }px solid grey`}
    >
      <textarea
        bind:value={newComment}
        rows="3"
        style={`width: 100%; font-size: 1.3em; background: black;color:white;border: 0px solid rgb(90, 58, 81); padding: 5px; border-radius: 15px`}
        placeholder="Write your reply."
      />
      <DisplayButton
        {principal}
        label="Post"
        {signIn}
        execute={async () => {
          processing = true
          await submitReply()
          processing = false
        }}
        {processing}
      />
      <div color="red">
        {errorResponse}
      </div>
    </div>

    {#each replies as post, i}
      <DisplayPost
        {auth}
        {principal}
        {signIn}
        {post}
        isThread={false}
        doNotShowBorder={i < replies.length - 1 ? false : true}
        doNotShowParent={true}
      />
    {/each}
  </div>
</div>

<style global>
  .icon-comment {
    width: 50px;
    display: flex;
    gap: 15px;
    color: grey;
  }

  .icon-comment:hover {
    color: skyblue;
  }

  .icon-retweet {
    width: 50px;
    display: flex;
    gap: 15px;
  }

  .icon-retweet:hover {
    color: greenyellow;
  }

  .icon-heart {
    width: 50px;
    display: flex;
    gap: 15px;
  }

  .icon-heart:hover {
    color: red;
  }
</style>
