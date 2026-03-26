cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.48"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.48/agentshield_0.2.48_darwin_amd64.tar.gz"
      sha256 "525d43388aca2abcc7c3a11626fcf5b5525c37d889a3a031518b90a2d39209e2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.48/agentshield_0.2.48_darwin_arm64.tar.gz"
      sha256 "b9ba3a3bdd32955819d0b1bf53b89bb81bae225c4b3068141e1a03e3c2f6ae33"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.48/agentshield_0.2.48_linux_amd64.tar.gz"
      sha256 "ea4b9fa9f09803dbc6f588ec628f0d1a42337adf0489bee9870fe4926b80275e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.48/agentshield_0.2.48_linux_arm64.tar.gz"
      sha256 "235c7d7bafaed8db4f534140e17a6877793565dd8dc172a6fe85b82eb6c1fb2c"
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
