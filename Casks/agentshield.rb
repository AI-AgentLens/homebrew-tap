cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.572"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.572/agentshield_0.2.572_darwin_amd64.tar.gz"
      sha256 "eb2437d2094346abe3008c770e8e81daa4f9a93ea25aefc2321c3825cb466f9f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.572/agentshield_0.2.572_darwin_arm64.tar.gz"
      sha256 "10a30ef98c490fbdd07eecea892d28dc1ceaed327f1fb868b8c9cda67ae0a645"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.572/agentshield_0.2.572_linux_amd64.tar.gz"
      sha256 "ab1d28eb6c4b04d80b747e20d3a18fb456b843f45105ae99958602b137ce3468"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.572/agentshield_0.2.572_linux_arm64.tar.gz"
      sha256 "da6a4d5981af67c7a9f7c93e7e1826fe973552bb144d8241c1e62cd9d26ba33d"
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
