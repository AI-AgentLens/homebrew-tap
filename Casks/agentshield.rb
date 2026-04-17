cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.621"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.621/agentshield_0.2.621_darwin_amd64.tar.gz"
      sha256 "35d4dad72cafe8324a62d7994f0a37736158d9813305376054b4367259a0316b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.621/agentshield_0.2.621_darwin_arm64.tar.gz"
      sha256 "2fa7b5bfd2d58bdfc8f3873fa41e7b2ed7639e367b804865ea69d8e9f71ea29f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.621/agentshield_0.2.621_linux_amd64.tar.gz"
      sha256 "434c7566ca5348aadf31483839110a7757f42fe4e8ab7fa9990e1fedc71ad734"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.621/agentshield_0.2.621_linux_arm64.tar.gz"
      sha256 "fcbe20418295d5eb8a73ec7f12515cdcc1033489e26237080daf3db55aad3281"
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
