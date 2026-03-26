cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.14"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.14/agentshield_0.2.14_darwin_amd64.tar.gz"
      sha256 "0472d9c135b177354d5a2fbc91586b4e767c2b13bb36bfb77a46013c5ce84a4f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.14/agentshield_0.2.14_darwin_arm64.tar.gz"
      sha256 "dc7ca287915eb9d5eee6d36a2d3f3037c738d6fe7a8c99e7c67d4f8d1ca6e4c4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.14/agentshield_0.2.14_linux_amd64.tar.gz"
      sha256 "e1c62eb3827ee342b1942c7f6f0b14f157b900b7658f4e186114a86f4d06b436"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.14/agentshield_0.2.14_linux_arm64.tar.gz"
      sha256 "03ff04ac4782d3c99460e49eb03dd64a5817fa632a96d895b8716ec31dad0d1b"
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
