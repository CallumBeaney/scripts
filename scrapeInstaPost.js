// https://caiorss.github.io/bookmarklet-maker/

// TODO: fix the content permissions issue for multiple images. 

const instaImageWrapper = "_aagv";

!async function main() {
  const url = window.location.href;
  if (!isValidUrl(url)) return;
  if (!isInstagramPost(url)) return;
  
  let nextButton = document.querySelector('button[aria-label="Next"]');

  // if (!nextButton) {
    // only one image
    const wrapper = window.document.querySelector(`.${instaImageWrapper}`);
    openImg(wrapper);
    return;
  // } 

  // let backButton = document.querySelector('button[aria-label="Go back"]');

  // // yes this is cursed, fight me
  // while (true) {
  //   console.log("here3")
  //   await sleep(100);
  //   nextButton.click();
  //   await sleep(100);
  //   nextButton = document.querySelector('button[aria-label="Next"]');
  //   // backButton = document.querySelector('button[aria-label="Go back"]');
  //   if (!nextButton) break;
  // }

  // const wrappers = window.document.querySelectorAll(`.${instaImageWrapper}`);
  // wrappers.forEach((w) => openImg(w));
  

}();

async function openImg(wrapper) {
  const imgElement = wrapper.querySelector('img');
  const src = imgElement.getAttribute('src');
  if (!isValidUrl(src)) return;

  let link = document.createElement('a');
  link.href = src;
  link.target = '_blank';
  link.rel = 'noopener noreferrer';
  link.click();
  link.remove();
  await sleep(200);
}

function isInstagramPost(url) {
  const instagramRegex = /^https?:\/\/(?:www\.)?instagram\.com\/p\/[a-zA-Z0-9_-]+\/?/;
  return instagramRegex.test(url);
}

function isValidUrl(string) {
  console.log(string);
  try {
    new URL(string);
    return true;
  } catch (err) {
    // console.error(`Not valid url: ${err}`);
    return false;
  }
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
