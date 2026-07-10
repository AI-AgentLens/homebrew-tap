cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1601"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1601/agentshield_0.2.1601_darwin_amd64.tar.gz"
      sha256 "fe06cc66218c186225efd7beadf2e0990268cef6a951ad07c74905b69617c30f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1601/agentshield_0.2.1601_darwin_arm64.tar.gz"
      sha256 "3b2bb23bc0f2156d3edfd05a0836dc9d9d68d49e69c7ac6a2ed804aad201245d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1601/agentshield_0.2.1601_linux_amd64.tar.gz"
      sha256 "fcb99296c7092f7a7bc8c89f6141345652c3df826888cb2ca169c2853dd9e5e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1601/agentshield_0.2.1601_linux_arm64.tar.gz"
      sha256 "c39a8f63689084c4e4972ef6c89faf6599f7e1a9bff59c24ab0867bcce6f8d75"
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
