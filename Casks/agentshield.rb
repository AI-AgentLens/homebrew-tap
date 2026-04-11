cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.541"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.541/agentshield_0.2.541_darwin_amd64.tar.gz"
      sha256 "ea955db558ecbc02797fe0655d09eb3122d2208aa69e4b5a7ef0f4d9896f7f54"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.541/agentshield_0.2.541_darwin_arm64.tar.gz"
      sha256 "aa0c48b01e28e34b420d70d8e095f497f7d23ddcf15f967c1dbe99810ccae6a0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.541/agentshield_0.2.541_linux_amd64.tar.gz"
      sha256 "915ae8bb72fdedcdffcb5bab3cfa73fb4b831cd9f72a1ffb8ac131fef7e48718"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.541/agentshield_0.2.541_linux_arm64.tar.gz"
      sha256 "3b7fc30701b9f40fd5136d0808b918195bfa793c775f75f086477e372f967c6c"
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
