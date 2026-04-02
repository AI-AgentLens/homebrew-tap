cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.312"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.312/agentshield_0.2.312_darwin_amd64.tar.gz"
      sha256 "dc675e52b16676500d610e0e39f723644fe1e83b79e0a220f5a517cfe59bddc3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.312/agentshield_0.2.312_darwin_arm64.tar.gz"
      sha256 "fd5129cc11d7133c40385b4874bfd70b2b25988cd7a38ec749a9590357e850a7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.312/agentshield_0.2.312_linux_amd64.tar.gz"
      sha256 "62bc1f56e12ef5c72de4255e5bf01383a39135793407eb7519af25e971fec66f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.312/agentshield_0.2.312_linux_arm64.tar.gz"
      sha256 "1698009f02510c4fb7aed478f34b241e5b725127d8986cbc35055dc8a7ec7551"
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
