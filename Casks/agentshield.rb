cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.564"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.564/agentshield_0.2.564_darwin_amd64.tar.gz"
      sha256 "0540f47a1f61a47b287c15651c9f53e016dc0a72dea47a47de32da9b88d5187a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.564/agentshield_0.2.564_darwin_arm64.tar.gz"
      sha256 "5374b7e691f1ef3366586e222bafc9b0598fa6a1044d1f7f3ec349d14814f040"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.564/agentshield_0.2.564_linux_amd64.tar.gz"
      sha256 "a752ad19d99e44b66f898960f0d09c749296356fbbab3b6bef8175da9e080de7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.564/agentshield_0.2.564_linux_arm64.tar.gz"
      sha256 "2836cf6ebf74e351795499774c61e5a9d7f15e066d17a05da7f762ea8c05db79"
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
