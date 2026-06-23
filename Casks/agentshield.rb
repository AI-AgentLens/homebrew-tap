cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1420"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1420/agentshield_0.2.1420_darwin_amd64.tar.gz"
      sha256 "fcba34d8c97f0f1baad7231033e5c33154243698e3043b2cb35a0ded07fd30aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1420/agentshield_0.2.1420_darwin_arm64.tar.gz"
      sha256 "b371ba1d82b10fe79a5aba791f34d86302a361491a0bcfef233bb5db4a9d07a2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1420/agentshield_0.2.1420_linux_amd64.tar.gz"
      sha256 "c722b3a69c569d980e1d092bb07919aea26551fbc3fb44b6634170916fcd2f61"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1420/agentshield_0.2.1420_linux_arm64.tar.gz"
      sha256 "f8dc6943248d291bd9058e58be17b4219a7de37a29b5cebaf94a8932b4dcf933"
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
