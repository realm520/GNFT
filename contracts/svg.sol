//SPDX-License-Identifier: <SPDX-License>

pragma solidity >=0.8.4;
import '@openzeppelin/contracts/utils/Strings.sol';
import 'base64-sol/base64.sol';

contract XPlanetSVG {
  using Strings for uint256;

  struct SVGParams {
    uint suit;
    string quoteTokenAddress;
    string baseTokenAddress;
    string quoteTokenSymbol;
    string baseTokenSymbol;
    uint256 tokenId;
    uint rank;
    string community;
  }

  mapping(uint => string) rankSVG; 
/*function tokenURL(params) {
    string name = generateName()
    string description = generateDescription()
    string image = Base64.encode(generateSVG(params))
    return string(
      abi.encodePacked(
        'data:application/json;base64,',
        Base64.encode(
          abi.encodePacked(
            '{"name":"',
            name,
            '", "description":"',
            description,
            '", "image": "',
            'data:image/svg+xml;base64,',
            image,
            '"}'
          )
        )
      )
    )
}*/
  
  constructor() {
    rankSVG[2] = '2';
    rankSVG[3] = '3';
    rankSVG[4] = '4';
    rankSVG[5] = '5';
    rankSVG[6] = '6';
    rankSVG[7] = '7';
    rankSVG[8] = '8';
    rankSVG[9] = '9';
    rankSVG[10] = '10';
    rankSVG[11] = 'J';
    rankSVG[12] = 'Q';
    rankSVG[13] = 'K';
    rankSVG[14] = 'A';
  }

  function generateName() internal pure returns (string memory) {
    return string(abi.encodePacked('xPlanet xPoker'));
  }
  
  function generateDescription() internal pure returns (string memory) {
    return string(abi.encodePacked('xPlanet xSwap Liquidity NFT'));
  }
  
  function generateSVG(SVGParams memory params) public view returns (string memory) {
    return Base64.encode((
      abi.encodePacked(
        '<svg width="630" height="880" viewBox="0 0 630 880" xmlns="http://www.w3.org/2000/svg"',
        ' xmlns:xlink="http://www.w3.org/1999/xlink">',
        generateSVGDefs(params.suit),
        generateSVGBackground(),
        generateSVGBorderText(
          params.quoteTokenAddress,
          params.baseTokenAddress,
          params.quoteTokenSymbol,
          params.baseTokenSymbol
        ),
        generateSVGText(
          params.tokenId,
          params.quoteTokenSymbol,
          params.baseTokenSymbol
        ),
        generateSVGSuit(params.suit),
        generateSVGRank(params.rank, params.suit),
        generateSVGIcon(params.community),
        '</svg>'
      )
    ));
  }
  
  function generateSVGDefs(uint suit) private pure returns (string memory) {
    require(suit < 4 && suit > 0, 'generateSVGDefs: Invalid suit');
    string[4] memory suitDefs = [
      '<feColorMatrix type="matrix" values="0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0.4 0"></feColorMatrix>',
      '<feColorMatrix type="matrix" values="0 0 0 0 1 0 0 0 0 0.1 0 0 0 0 0.1 0 0 0 0.6 0"></feColorMatrix>',
      '<feColorMatrix type="matrix" values="0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0.4 0"></feColorMatrix>',
      '<feColorMatrix type="matrix" values="0 0 0 0 1 0 0 0 0 0.1 0 0 0 0 0.1 0 0 0 0.6 0"></feColorMatrix>'
    ];
    return string(
      abi.encodePacked(
        '<defs>',
        '<linearGradient id="paint0_linear" x1="0" y1="0" x2="630" y2="880" gradientUnits="userSpaceOnUse">',
        '<stop stop-color="#1F1F1F"/>',
        '<stop offset="1" stop-color="#141414"/>',
        '</linearGradient>',
        '<filter id="filter1_d" x="-50" y="76" width="840" height="840" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">',
        '<feFlood flood-opacity="0" result="BackgroundImageFix"></feFlood>',
        '<feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"></feColorMatrix>',
        '<feOffset></feOffset>',
        '<feGaussianBlur stdDeviation="100"></feGaussianBlur>',
        suitDefs[suit - 1],
        '<feBlend mode="normal" in2="BackgroundImageFix" result="effect1_dropShadow"></feBlend>',
        '<feBlend mode="normal" in="SourceGraphic" in2="effect1_dropShadow" result="shape"></feBlend>',
        '</filter>',
        '<path id="text-path-a" d="M50 30 H580 A20 20 0 0 1 600 50 V830 A20 20 0 0 1 580 850 H50 A20 20 0 0 1 30 830 V50 A20 20 0 0 1 50 30 z"></path>',
        '</defs>'
      )
    );
  }
  
  function generateSVGBackground() private pure returns (string memory) {
    return string(
      abi.encodePacked(
        '<path d="M0 32C0 14.3269 14.3269 0 32 0H598C615.673 0 630 14.3269 630 32V848C630 865.673 615.673 880 598 880H32C14.3269 880 0 865.673 0 848V32Z" fill="url(#paint0_linear)"/>',
        '<rect x="40" y="40" width="550" height="800" fill="transparent" stroke="white" stroke-opacity="0.16"/>',
        '<path d="M40 200H590" stroke="white" stroke-opacity="0.16"/>',
        '<path d="M40 360H590" stroke="white" stroke-opacity="0.16"/>',
        '<path d="M40 520H590" stroke="white" stroke-opacity="0.16"/>',
        '<path d="M40 680H590" stroke="white" stroke-opacity="0.16"/>',
        '<path d="M150 40V840" stroke="white" stroke-opacity="0.16"/>',
        '<path d="M260 40V840" stroke="white" stroke-opacity="0.16"/>',
        '<path d="M370 40V840" stroke="white" stroke-opacity="0.16"/>',
        '<path d="M480 40V840" stroke="white" stroke-opacity="0.16"/>'
      )
    );
  }
  
  function generateSVGBorderText(
      string memory quoteTokenAddress,
      string memory baseTokenAddress,
      string memory quoteTokenSymbol,
      string memory baseTokenSymbol
  ) private pure returns (string memory svg) {
    
    svg = string(
      abi.encodePacked(
        '<text text-rendering="optimizeSpeed">',
        '<textPath startOffset="-100%" fill="rgb(255,255,255,1)" fill-opacity="0.6" font-family="Roboto Mono" font-size="24px" xlink:href="#text-path-a">',
        baseTokenAddress,
        unicode' • ',
        baseTokenSymbol,
        ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
        '</textPath> <textPath startOffset="0%" fill="rgb(255,255,255,1)" fill-opacity="0.6" font-family="Roboto Mono" font-size="24px" xlink:href="#text-path-a">',
        baseTokenAddress,
        unicode' • ',
        baseTokenSymbol,
        ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /> </textPath>',
        '<textPath startOffset="50%" fill="rgb(255,255,255,1)" fill-opacity="0.6" font-family="Roboto Mono" font-size="24px" xlink:href="#text-path-a">',
        quoteTokenAddress,
        unicode' • ',
        quoteTokenSymbol,
        ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s"',
        ' repeatCount="indefinite" /></textPath><textPath startOffset="-50%" fill="rgb(255,255,255,1)" fill-opacity="0.6" font-family="Roboto Mono" font-size="24px" xlink:href="#text-path-a">',
        quoteTokenAddress,
        unicode' • ',
        quoteTokenSymbol,
        ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /></textPath></text>'
      )
    );
    return svg;
  }
  
  function generateSVGText(uint256 tokenId, string memory quoteTokenSymbol, string memory baseTokenSymbol) private pure returns (string memory) {
    return string(
      abi.encodePacked(
        '<g mask="url(#fade-symbol)"><rect fill="none" x="0px" y="0px" width="630" height="440" />',
        '<text x="50" y="120" fill="rgb(255,255,255,1)" font-family="Roboto Mono" font-weight="bold" font-size="68px">',
        quoteTokenSymbol,
        '<tspan fill="yellow">',
        ' / ',
        '</tspan>',
        baseTokenSymbol,
        '</text>',
        '<text x="55" y="165" fill="rgb(255,255,255,1)" fill-opacity="0.8" font-family="Roboto Mono" font-weight="500" font-size="22px">ID: ',
        tokenId.toString(),
        '</text></g>'
      )
    );
  }
  
  function generateSVGSuit(uint suit) private pure returns (string memory) {
    require(suit<4, 'generateSVGSuit: Invalid suit');
    string[4] memory suitSVG = [
      string(abi.encodePacked('<g filter="url(#filter1_d)">',
        '<circle cx="440.711" cy="511.132" r="100" transform="rotate(-135 440.711 511.132)" fill="white" fill-opacity="0.8"></circle>',
        '<circle cx="299.289" cy="511.132" r="100" transform="rotate(-135 299.289 511.132)" fill="white" fill-opacity="0.8"></circle>',
        '<rect x="370" y="581.843" width="200" height="200" transform="rotate(-135 370 581.843)" fill="white" fill-opacity="0.8"></rect>',
        '<path d="M370 609.579L299.289 680.289H440.711L370 609.579Z" fill="white" fill-opacity="0.8"></path>',
      '</g>',
      '<path d="M480 355C480 357.761 477.761 360 475 360C477.761 360 480 362.239 480 365C480 362.239 482.239 360 485 360C482.239 360 480 357.761 480 355Z" fill="white"></path>',
      '<path d="M260 675C260 677.761 257.761 680 255 680C257.761 680 260 682.239 260 685C260 682.239 262.239 680 265 680C262.239 680 260 677.761 260 675Z" fill="white"></path>',
      '<path d="M150 195C150 197.761 147.761 200 145 200C147.761 200 150 202.239 150 205C150 202.239 152.239 200 155 200C152.239 200 150 197.761 150 195Z" fill="white"></path>'))
      ,
      string(abi.encodePacked('<g filter="url(#filter1_d)">',
        '<circle cx="291.3" cy="433.299" r="111.299" transform="rotate(90 291.3 433.299)" fill="#FF1C1C" fill-opacity="0.6"></circle>',
        '<circle cx="448.701" cy="433.299" r="111.299" transform="rotate(90 448.701 433.299)" fill="#FF1C1C" fill-opacity="0.6"></circle>',
        '<rect x="370" y="354.599" width="222.599" height="222.599" transform="rotate(45 370 354.599)" fill="#FF1C1C" fill-opacity="0.6"></rect>',
      '</g>',
      '<path d="M260 195C260 197.761 257.761 200 255 200C257.761 200 260 202.239 260 205C260 202.239 262.239 200 265 200C262.239 200 260 197.761 260 195Z" fill="white"></path>',
      '<path d="M150 515C150 517.761 147.761 520 145 520C147.761 520 150 522.239 150 525C150 522.239 152.239 520 155 520C152.239 520 150 517.761 150 515Z" fill="white"></path>',
      '<path d="M480 675C480 677.761 477.761 680 475 680C477.761 680 480 682.239 480 685C480 682.239 482.239 680 485 680C482.239 680 480 677.761 480 675Z" fill="white"></path>'))
      ,
  
      string(abi.encodePacked('<g filter="url(#filter1_d)">',
        '<circle cx="454" cy="521" r="100" fill="white" fill-opacity="0.8"></circle>',
        '<circle cx="284" cy="521" r="100" fill="white" fill-opacity="0.8"></circle>',
        '<circle cx="369" cy="401" r="100" fill="white" fill-opacity="0.8"></circle>',
        '<path d="M369 609.579L298.289 680.289H439.711L369 609.579Z" fill="white" fill-opacity="0.8"></path>',
      '</g>',
      '<path d="M480 195C480 197.761 477.761 200 475 200C477.761 200 480 202.239 480 205C480 202.239 482.239 200 485 200C482.239 200 480 197.761 480 195Z" fill="white"></path>',
      '<path d="M150 355C150 357.761 147.761 360 145 360C147.761 360 150 362.239 150 365C150 362.239 152.239 360 155 360C152.239 360 150 357.761 150 355Z" fill="white"></path>',
      '<path d="M150 675C150 677.761 147.761 680 145 680C147.761 680 150 682.239 150 685C150 682.239 152.239 680 155 680C152.239 680 150 677.761 150 675Z" fill="white"></path>'))
      ,
  
      string(abi.encodePacked('<g filter="url(#filter1_d)">',
        '<path fill-rule="evenodd" clip-rule="evenodd" d="M370 304.002V496.001H561.996C561.997 496.001 561.998 496 561.999 496C478.447 455.409 410.59 387.554 370 304.002Z" fill="#FF1D1D" fill-opacity="0.7"></path>',
        '<path fill-rule="evenodd" clip-rule="evenodd" d="M561.996 496.001H370V687.997C410.59 604.447 478.445 536.592 561.996 496.001Z" fill="#FF1D1D" fill-opacity="0.9"></path>',
        '<path fill-rule="evenodd" clip-rule="evenodd" d="M178 496C261.553 455.409 329.41 387.554 370 304.001V496.001H178.003C178.002 496.001 178.001 496 178 496Z" fill="#FF1D1D" fill-opacity="0.9"></path>',
        '<path fill-rule="evenodd" clip-rule="evenodd" d="M370.004 687.989V496.001H178.004V496.002C261.555 536.593 329.41 604.448 369.999 687.998C370.001 687.995 370.002 687.992 370.004 687.989Z" fill="#FF1D1D" fill-opacity="0.7"></path>',
      '</g>',
      '<path d="M150 355C150 357.761 147.761 360 145 360C147.761 360 150 362.239 150 365C150 362.239 152.239 360 155 360C152.239 360 150 357.761 150 355Z" fill="white"></path>',
      '<path d="M370 195C370 197.761 367.761 200 365 200C367.761 200 370 202.239 370 205C370 202.239 372.239 200 375 200C372.239 200 370 197.761 370 195Z" fill="white"></path>',
      '<path d="M150 675C150 677.761 147.761 680 145 680C147.761 680 150 682.239 150 685C150 682.239 152.239 680 155 680C152.239 680 150 677.761 150 675Z" fill="white"></path>'))
    ];
    return string(abi.encodePacked(suitSVG[suit - 1]));
  }
  
  function generateSVGRank(uint rank, uint suit) internal view returns (string memory) {
    require(suit > 0 && suit < 5, "generateSVGRank: invalid suit");
    require(rank > 1 && suit < 15, "generateSVGRank: invalid rank");
    string[4] memory suitSVGColor = ['white', '#FF1C1C', 'white', '#FF1C1C'];
    string[4] memory suitIcon = [
      '<path fill-rule="evenodd" clip-rule="evenodd" d="M461.001 800.882L461.001 800.882C453.619 808.263 441.652 808.263 434.27 800.881C426.889 793.5 426.889 781.532 434.27 774.151C434.314 774.108 434.357 774.064 434.401 774.022L461.001 747.421L487.602 774.022C487.645 774.065 487.689 774.108 487.732 774.151C495.114 781.532 495.114 793.5 487.732 800.881C480.351 808.263 468.383 808.263 461.002 800.882L461.001 800.882ZM445.096 822.127L461.134 806.088L477.173 822.127H445.096Z" fill="white"></path>',
      '<path fill-rule="evenodd" clip-rule="evenodd" d="M460.998 761.706C452.979 753.688 439.978 753.688 431.96 761.707C423.941 769.725 423.941 782.726 431.96 790.745C432.004 790.789 432.048 790.833 432.092 790.877L460.998 819.783L489.875 790.906C489.929 790.853 489.983 790.799 490.037 790.746C498.056 782.727 498.056 769.726 490.037 761.707C482.019 753.689 469.018 753.688 460.999 761.706L460.998 761.706L460.998 761.706Z" fill="#FF1C1C"></path>',
      '<path fill-rule="evenodd" clip-rule="evenodd" d="M479.63 771.299C479.63 772.628 479.491 773.926 479.226 775.177C488.386 776.35 495.465 784.176 495.465 793.655C495.465 803.945 487.124 812.286 476.835 812.286C470.149 812.286 464.286 808.764 460.999 803.475C457.712 808.764 451.849 812.286 445.164 812.286C434.874 812.286 426.533 803.945 426.533 793.655C426.533 784.176 433.613 776.35 442.773 775.177C442.508 773.926 442.369 772.628 442.369 771.299C442.369 761.009 450.71 752.668 460.999 752.668C471.289 752.668 479.63 761.009 479.63 771.299ZM446.176 826.134L460.975 811.335L475.775 826.134H446.176Z" fill="white"></path>',
      '<path fill-rule="evenodd" clip-rule="evenodd" d="M416.001 745.866C407.939 762.461 394.462 775.938 377.867 784C394.462 792.061 407.939 805.538 416.001 822.133C424.062 805.538 437.539 792.061 454.134 784C437.539 775.938 424.062 762.461 416.001 745.866Z" fill="#FF1C1C"></path>'
    ];
    return string(
      abi.encodePacked(
        '<g>',
        suitIcon[suit - 1],
        '<text x="500" y="820" font-family="\'Roboto Mono\', monospace" font-size="80px" font-weight="bold" fill="',
        suitSVGColor[suit - 1],
        '">',
        rankSVG[rank],
        '</text></g>'
      )
    );
  }
  
  function generateSVGIcon(string memory name) private pure returns (string memory) {
    uint len = bytes(name).length;
  
    return string(
      abi.encodePacked(
        '<g>',
        '<rect x="60" y="770" width="',
        (18 * len).toString(),
        '" height="48" rx="10" ry="10" fill="rgb(255,255,255,1)" fill-opacity="0.5" />',
        '<text x="78" y="800" font-family="\'Roboto Mono\', monospace" font-size="24px" font-weight="bold" fill="rgb(0,0,0,1)">',
        name,
        '</text></g>'
      )
    );
  }
}  

  
