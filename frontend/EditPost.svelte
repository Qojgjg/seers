<script lang="ts">
  import { onMount } from "svelte"
  import { useNavigate } from "svelte-navigator"
  import inf from "./assets/inf.gif"

  import DisplayButton from "./DisplayButton.svelte"

  export let id
  export let auth
  export let principal
  export let signIn

  const navigate = useNavigate()

  let content = ""
  let amount = 0.5
  let post
  let errorResponse = ""
  let processing = false
  let anonImage =
    "https://static.wikia.nocookie.net/codegeass/images/c/c0/Zero.jpg"

  const getPost = async () => {
    post = await $auth.actor.getThread(Number(id))
    if ("ok" in post) {
      console.log(post)
      post = post["ok"].main
      content = post.content
    } else {
      console.log(post["err"])
    }
  }

  const submitEdit = async () => {
    let initData = {
      id: post.id,
      author: post.author,
      content: content,
      parent: post.parent,
      image: post.image,
      market: post.market,
      retweet: post.retweet,
      isRetweet: post.isRetweet,
    }
    const resp = await $auth.actor.editPost(initData, [])
    if ("ok" in resp) {
      navigate(`/post/${post.id}`)
    } else {
      errorResponse = resp["err"]
    }
  }

  onMount(getPost)
</script>

<div style="width: 100%; display:flex; justify-content:center">
  <div class="rowUser">
    <div
      id="main"
      style="padding: 0px 0px 0px 0px; width: 100%; border-top: 0px solid grey; "
    >
      <div
        style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 5px 0px; flex-direction:row; align-items:center; font-size: 1.2em; "
      >
        <div style="padding: 0px 0px; margin: 0px 5px; height: 100%;">
          <a href={`/profile/${post?.author.handle}`}>
            <img
              src={post?.author.picture ? post?.author.picture : anonImage}
              alt="avatar"
              style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%"
            />
          </a>
        </div>
        <div style="display:flex; flex-direction:column; height: 100%">
          <a href={`/profile/${post?.author.handle}`}>{post?.author.name}</a>
          <a href={`/profile/${post?.author.handle}`} style="color:grey">
            @{post?.author.handle}
          </a>
        </div>
      </div>
      <div style="flex-grow: 1; justify-content: start; text-align:start">
        <div
          style="width: 100%; text-align:start; padding: 0px 0px; border-bottom: 0px solid grey;"
        >
          <div style="padding: 10px 0px; background:black">
            <input
              bind:value={content}
              style="background:black;color:white; border: 0; font-size: 1.2em; width: 100%"
            />
          </div>
        </div>
        {#if post && post.market.length > 0}
          <div>
            {#each post.market[0].labels as label, i}
              <div
                style="width: 100%; display:flex; cursor:pointer; margin: 0; padding: 0;"
              >
                <div
                  style={`background: ${
                    post.market[0].selected == i ||
                    (post.market[0].selected === undefined && i == 0)
                      ? "#FFDC00"
                      : "#39CCCC"
                  }; width: 100px; padding: 5px 0px 0px 0px; margin: 2px 0px; border: 0px solid black; border-radius: 5px 0px 0px 5px; color:black; text-align:right`}
                >
                  <button
                    style="all:unset; width: 100%"
                    on:click={() => {
                      post.market[0].selected = i
                    }}
                  >
                    {label}
                  </button>
                </div>
                <div style="flex-grow: 1;">
                  <div
                    style={`background: ${
                      post.market[0].selected == i ||
                      (post.market[0].selected === undefined && i == 0)
                        ? "#FFDC00"
                        : "#39CCCC"
                    }; width: ${
                      post.market[0].probabilities[i] * 100.0
                    }%; padding: 5px 0px; margin: 2px 0px; border: 0px solid black; border-radius: 0px 5px 5px 0px; color:black`}
                  >
                    <button
                      style="all:unset; width: 100%"
                      on:click={() => {
                        post.market[0].selected = i
                      }}
                    />
                  </div>
                </div>
                <div
                  style="width: 100px; justify-content:flex-end; text-align:end; margin-right: 30px; padding: 5px"
                >
                  {post.market[0].probabilities[i].toFixed(2)}
                  {"seers" in post.market[0].collateralType ? "Σ" : "ICP"}
                </div>
              </div>
            {/each}
            <div
              style="display:flex; text-align:end; justify-content:start; flex-grow: 1"
            >
              {#if processing}
                <input bind:value={amount} />
                <button
                  class="btn-grad"
                  style="background: black;width: 100px; margin: 15px 0px; color:white;overflow:hidden;"
                >
                  <img
                    src={inf}
                    alt="inf"
                    style="width: 150px; height: 400%; margin: -100%;"
                  />
                </button>
                <input
                  style="color: rgb(255, 255, 255); background-color: black; font-size: 1.2em; font-family: 'Roboto Mono', monospace; border: 0px; padding: 0px 5px; margin: 0px 15px; width: 50px"
                  bind:value={amount}
                />
                <div
                  style="display:flex; text-align:center; align-items:center; padding: 0px 5px"
                >
                  {"seers" in post.market[0].collateralType ? "Σ" : "ICP"}
                </div>
              {:else}
                <button
                  class="btn-grad"
                  style="background: black; padding: 5px; margin: 15px 0px; color: white"
                  >Buy</button
                >
                <input
                  style="color: rgb(255, 255, 255); background-color: black; font-size: 1.2em; font-family: 'Roboto Mono', monospace; border: 0px; padding: 0px 5px; margin: 0px 15px; width: 50px"
                  bind:value={amount}
                />
                <div
                  style="display:flex; text-align:center; align-items:center; padding: 0px 5px"
                >
                  {"seers" in post.market[0].collateralType ? "Σ" : "ICP"}
                </div>
              {/if}
              <div style="text-align:center;color:red">
                {errorResponse}
              </div>
            </div>
          </div>
        {:else if post && post.image.length > 0}
          <div>
            <img
              src={post.image[0]}
              alt="main"
              style="width: 95%; border-radius: 15px; object-fit:cover"
            />
          </div>
        {/if}
      </div>
      <DisplayButton
        {principal}
        label="Submit"
        {signIn}
        execute={async () => {
          processing = true
          await submitEdit()
          processing = false
        }}
        {processing}
      />
    </div>
  </div>
</div>

<style>
  .menu-button-elli {
    background-color: black;
    width: 10px;
    justify-content: start;
    text-align: start;
    padding: 0px 0px;
    cursor: pointer;
  }

  .menu-button-elli:hover {
    color: #1da1f2;
  }

  .like-bt {
    all: unset;
    cursor: pointer;
  }
  .like-bt:hover {
    color: #e81c4f;
  }

  .retweet-bt {
    all: unset;
    cursor: pointer;
  }
  .retweet-bt:hover {
    color: #19cf86;
  }

  .reply-bt {
    all: unset;
    cursor: pointer;
  }
  .reply-bt:hover {
    color: #1da1f2;
  }
  /* Dropdown Button */
  .dropbtn {
    background-color: black;
    color: grey;
    padding: 0px;
    font-size: 16px;
    border: none;
  }

  /* The container <div> - needed to position the dropdown content */
  .dropdown {
    position: relative;
    display: inline-block;
  }

  /* Dropdown Content (Hidden by Default) */
  .dropdown-content {
    display: none;
    position: absolute;
    background-color: black;
    min-width: 160px;
    margin-left: -120px;
    box-shadow: 0px 8px 16px 0px rgba(0, 0, 0, 0.2);
    z-index: 1;
  }

  /* Links inside the dropdown */
  .dropdown-content a {
    color: white;
    padding: 12px 16px;
    text-decoration: none;
    display: block;
  }

  /* Change color of dropdown links on hover */
  .dropdown-content a:hover {
    background-color: black;
  }

  /* Show the dropdown menu on hover */
  .dropdown:hover .dropdown-content {
    display: block;
  }

  /* Change the background color of the dropdown button when the dropdown content is shown */
  .dropdown:hover .dropbtn {
    background-color: black;
  }
</style>
