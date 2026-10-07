cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2372"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2372/agentshield_0.2.2372_darwin_amd64.tar.gz"
      sha256 "f5ca35b3234f4e9ecbb1eacbd92eca791bb9f2321fe0e6814ddf84c9aaf72c5c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2372/agentshield_0.2.2372_darwin_arm64.tar.gz"
      sha256 "bfc971e2f0c2e4828c7c948fb6964b2ad05a9b23ccc8fe53c162be3cd9893e98"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2372/agentshield_0.2.2372_linux_amd64.tar.gz"
      sha256 "98e1f0b959f0366181ee678d460e56c072d3dd57595470ff31ba601951e0c720"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2372/agentshield_0.2.2372_linux_arm64.tar.gz"
      sha256 "888a3e1b28620e672ed96c0ba16eda5344f44c92bea6ab8f7924a48ecf4ff479"
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
