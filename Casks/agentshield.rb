cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.360"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.360/agentshield_0.2.360_darwin_amd64.tar.gz"
      sha256 "a2d79c3dc8a93887f92bcba0fb3a70e998ffe35033a386d4d4911464949fa2cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.360/agentshield_0.2.360_darwin_arm64.tar.gz"
      sha256 "8dd4b93164b98639b2aae29b45cd307d9faebee4c4f3c9f03a8c26dd999af71e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.360/agentshield_0.2.360_linux_amd64.tar.gz"
      sha256 "23dd3ca7014f1cfeb60ea81502a7055bd8185f1f6b86b6fa76c4b339bc442697"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.360/agentshield_0.2.360_linux_arm64.tar.gz"
      sha256 "20fee325b594a7115bf59c26a67b17f4298f4599b2b0b257b9b67739c60fdb9d"
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
