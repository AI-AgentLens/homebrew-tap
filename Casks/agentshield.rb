cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.992"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.992/agentshield_0.2.992_darwin_amd64.tar.gz"
      sha256 "e03c6b390b8f74a100d0d0c14446651ae41e46e1208eaa94766911f1bd0fa31e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.992/agentshield_0.2.992_darwin_arm64.tar.gz"
      sha256 "fe29bde8696fdb6dff3e797ccda49462c145a41e3db1116673d575de327963c5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.992/agentshield_0.2.992_linux_amd64.tar.gz"
      sha256 "cae08a0a48ce0ab477db73c95df8b834f181dcaae27d46f4f09ae940bd5e2acd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.992/agentshield_0.2.992_linux_arm64.tar.gz"
      sha256 "d2683d250d6a2a025274d5fe9238a12cd9dc3d277b5f2db8c373f4439d6e2d6d"
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
