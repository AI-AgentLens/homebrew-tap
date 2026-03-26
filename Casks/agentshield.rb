cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.73"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.73/agentshield_0.2.73_darwin_amd64.tar.gz"
      sha256 "ff47f1c5850182ddca3f3a77df71f5f102a54da055bf43268aa073e6482014ac"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.73/agentshield_0.2.73_darwin_arm64.tar.gz"
      sha256 "4e5d3c4c2bc57a6170ba0f28fde58b63354a655fd6ea348635206f8b727acc38"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.73/agentshield_0.2.73_linux_amd64.tar.gz"
      sha256 "fa1d8ab01c8f5ad3f76f75734c5c2f621d9b587d19642ee404c6274e0de07c23"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.73/agentshield_0.2.73_linux_arm64.tar.gz"
      sha256 "1f6a3bc6b0ed645b4fc83e7304961db5c2e26ae9982fa089258c14cb2cc1c959"
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
