cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1472"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1472/agentshield_0.2.1472_darwin_amd64.tar.gz"
      sha256 "a9dbd4023eae3ad971838c707c2cbf6eec673eedcd30fcf1161aa62741479822"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1472/agentshield_0.2.1472_darwin_arm64.tar.gz"
      sha256 "93b9f273f31e3e41ec32d26520f01fdc2fd36d95bc977254b0370afefc87a73a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1472/agentshield_0.2.1472_linux_amd64.tar.gz"
      sha256 "f5c7f8f6e79c7971c07dafc7ba715197fded1334fe366d54f2009f94f006d179"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1472/agentshield_0.2.1472_linux_arm64.tar.gz"
      sha256 "c9e4823a84a795fdf38062534449c08dbbef28914cbd945cf9ee2e0f60566cd0"
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
