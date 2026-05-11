cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.948"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.948/agentshield_0.2.948_darwin_amd64.tar.gz"
      sha256 "5499501d4b2f2ce1978f7a9770dfb86c4c78cf7a3ce964c03fa96c520f4b28f7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.948/agentshield_0.2.948_darwin_arm64.tar.gz"
      sha256 "b49ea8bb9a70dba1918a02df5a8356b9f2bb1a1f1ecf6de982d5b88c9a4ee7fa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.948/agentshield_0.2.948_linux_amd64.tar.gz"
      sha256 "dbe8fad2b2097188d0464271bfc5b1dfc086be32197a74f29c2cef6200f39a67"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.948/agentshield_0.2.948_linux_arm64.tar.gz"
      sha256 "b56c3a7f2e817cb1e4c0fdc8313ede757c3386051edbea0b2e31da5e83dce6fa"
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
