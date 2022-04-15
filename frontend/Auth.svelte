<script lang="ts">
  import { Link } from "svelte-navigator"
  import Fa from "svelte-fa"
  import { faBars } from "@fortawesome/free-solid-svg-icons"
  import logo from "./assets/favicon.png"

  export let principal
  export let signOut
  export let signIn

  let navClass = "topnav"

  // function updateResponsive() {
  //   var x = document.getElementById("myTopnav")
  //   var classes = x.className.split(" ")
  //   if (classes.includes("responsive")) {
  //     //   navClass = "topnav responsive"
  //     // } else {
  //     navClass = "topnav"
  //   }
  // }

  function getProps({ location, href, isPartiallyCurrent, isCurrent }) {
    // const isActive = href === "/" ? isCurrent : isPartiallyCurrent || isCurrent

    // The object returned here is spread on the anchor element's attributes
    // if (isActive) {
    //   return { class: "active" }
    // }
    return { style: "padding: 5px" }
  }

  function getProps2({ location, href, isPartiallyCurrent, isCurrent }) {
    return { style: "padding: 5px", target: "_blank" }
  }
</script>

<div class={navClass} id="myTopnav">
  <a
    href="/"
    class="left"
    style="margin: 0; padding: 0; margin-right: 20px; margin-left: 20px"
    ><img
      src={logo}
      alt="logo"
      style="width: 80px; align-content:center; text-align:center;"
    /></a
  >

  <Link to="/" {getProps}>Markets</Link>
  <Link to="ranking" {getProps}>Ranking</Link>

  {#if principal === ""}
    <a href="https://forms.gle/fYmc9iTc9P46upm47">Bugs</a>
    <div style="display: block; width:fit-content;float:right">
      <button
        on:click={signIn}
        style="color: white; background-color: transparent; font-size: 17px;"
        >Login</button
      >
    </div>
  {/if}

  {#if principal !== ""}
    <Link to="profile" {getProps}>Profile</Link>
    <Link to="create" {getProps}>Create</Link>
    <a href="https://forms.gle/fYmc9iTc9P46upm47">Bugs</a>

    <button
      on:click={signOut}
      style="color: white; background-color: transparent; font-size: 17px;"
      >Logout</button
    >
  {/if}
  <a href="javascript:void(0);" class="icon">
    <Fa icon={faBars} />
  </a>
</div>

<style>
  .button {
    background-color: transparent;
  }
  .topnav {
    display: flex;
    flex-direction: row;
    align-items: center;
  }

  .right {
    padding: 5px;
  }

  .topnav button:hover {
    cursor: pointer;
  }

  .topnav .icon {
    display: none;
    color: white;
    font-size: 1.2em;
  }

  @media screen and (max-width: 600px) {
    .topnav a:not(:first-child) {
      display: none;
    }
    .topnav button:not(:first-child) {
      display: none;
    }
    .topnav a.icon {
      float: right;
      display: block;
      color: white;
    }
  }

  @media screen and (max-width: 600px) {
    .topnav.responsive .icon {
      position: absolute;
      right: 0;
      top: 0;
      color: white;
    }
    .topnav.responsive a.right {
      text-align: right;
      float: none;
      display: block;
    }
    .topnav.responsive a.left {
      float: none;
      display: block;
      text-align: left;
    }
    .topnav.responsive button {
      float: right;
      display: block;
      text-align: right;
    }
  }
</style>
