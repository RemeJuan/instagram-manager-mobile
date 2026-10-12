module.exports = function (eleventyConfig) {
  eleventyConfig.ignores.add("README.md");
  eleventyConfig.addPassthroughCopy("assets/styles");

  return {
    pathPrefix: "/",
    dir: {
      input: ".",
      output: "_site",
      includes: "_includes",
    },
    templateFormats: ["njk", "html"],
    htmlTemplateEngine: "njk",
  };
};
