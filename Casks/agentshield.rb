cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.26"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.26/agentshield_0.2.26_darwin_amd64.tar.gz"
      sha256 "c535a59b65ffcf953d99dd5134c138dc41cc2e44ae229edfe6e09cb213ed9ebf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.26/agentshield_0.2.26_darwin_arm64.tar.gz"
      sha256 "fe8855daf12ec7a5e8cb6f417a291ac7a00f84ae45e601ac92e60438bad06543"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.26/agentshield_0.2.26_linux_amd64.tar.gz"
      sha256 "80edbc877ded0b38b729328bce6a6fda6fdc4ede81f6924a6e705edbcac19cbd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.26/agentshield_0.2.26_linux_arm64.tar.gz"
      sha256 "0fedef7081b5420af3a0cbaa6ebf7d7cb2a307b09957a614272c92e4ab3a3a2f"
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
