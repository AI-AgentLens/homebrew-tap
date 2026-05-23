cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1099"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1099/agentshield_0.2.1099_darwin_amd64.tar.gz"
      sha256 "e0d3eb162ccd5f8135f9574172e230484628b87f6bf5aa48339b83a1ff1378e8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1099/agentshield_0.2.1099_darwin_arm64.tar.gz"
      sha256 "efdbd947d1fe11bcb827b49c604e659b11fd2e48d40a7eab0ecdbfad88af7d86"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1099/agentshield_0.2.1099_linux_amd64.tar.gz"
      sha256 "f289fd2e49d8d7aea6c47856b5515f341410a722661e18251f9c03402c8a454e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1099/agentshield_0.2.1099_linux_arm64.tar.gz"
      sha256 "932fd1217fa7e5e3a770eac53912fb7d4dcceb936edf880f2328299d0d687355"
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
