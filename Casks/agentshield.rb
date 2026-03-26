cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.33"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.33/agentshield_0.2.33_darwin_amd64.tar.gz"
      sha256 "784980f7464a9cb1039e97b7a6db1d85efcc5f3b6608e1867922f48cb4cf98f2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.33/agentshield_0.2.33_darwin_arm64.tar.gz"
      sha256 "2fa50b5d4ce24fdf35d6a74cdc613232d54f409cc0a8af67e439b60acdc2745a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.33/agentshield_0.2.33_linux_amd64.tar.gz"
      sha256 "8442cfbf8b3befaf60616afe96329c45275e1069a7704ee39674c7a632460e5d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.33/agentshield_0.2.33_linux_arm64.tar.gz"
      sha256 "66e463fd68c3e94539ac1966e504a74d4aa64ae0001d70926a81006f62c76400"
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
