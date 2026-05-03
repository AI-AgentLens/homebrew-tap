cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.858"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.858/agentshield_0.2.858_darwin_amd64.tar.gz"
      sha256 "67276ee4ba2c01fc9d9b5b9ac92f1b80b41760ce95f3ee5a3ed99b98bd5a80c8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.858/agentshield_0.2.858_darwin_arm64.tar.gz"
      sha256 "6e3815b379586405535c52a66347baf3923e84379d7f1c23178b1b4cff4ec820"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.858/agentshield_0.2.858_linux_amd64.tar.gz"
      sha256 "e0f55ed805e5c99d588fed4525271c489dd3111de7f56071d1a7c2212ce08a4d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.858/agentshield_0.2.858_linux_arm64.tar.gz"
      sha256 "eaacf7324e46a42c1abb6ae659ab1883152bb9438c1a7c9c552cbe2203f946c6"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
