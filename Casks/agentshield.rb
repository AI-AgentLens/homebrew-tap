cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.434"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.434/agentshield_0.2.434_darwin_amd64.tar.gz"
      sha256 "0f02d2348e9ea5e362e5a7f2e716c128c1c8c9cd4d0edf5265799c08abdbb503"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.434/agentshield_0.2.434_darwin_arm64.tar.gz"
      sha256 "48f8a3e504716c432008d3ac683574b880a58e4386165186c4aef6ade7dd1702"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.434/agentshield_0.2.434_linux_amd64.tar.gz"
      sha256 "c879233e34191f47b1f36c9183fa8bcb7a7cc34f4c84cd8f9757e8fd556b31ff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.434/agentshield_0.2.434_linux_arm64.tar.gz"
      sha256 "505b7917005ec5a27262b0fb6f024856f49846887cde109952848d91c197aee8"
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
